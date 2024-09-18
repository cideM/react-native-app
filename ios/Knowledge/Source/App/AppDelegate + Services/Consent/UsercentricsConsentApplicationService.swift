//
//  UsercentricsConsentApplicationService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Domain
import UIKit
import Usercentrics
import UsercentricsUI
import AppTrackingTransparency
import DesignSystem
import Networking

enum ConsentService {
    case adjust
}

protocol ConsentChangeListener {
    func consentDidChange(_ consents: [ConsentService: Bool])
}

final class UsercentricsConsentApplicationService: ConsentApplicationServiceType {
    private let configuration: Configuration
    private let consentChangeListeners: [ConsentChangeListener]
    private let storage: Storage

    private var authorizationObserver: NSObjectProtocol?
    @LazyInject private var monitor: Monitoring

    var completion: ((Bool) -> Void)?
    var initialConsentDialogWasShown: Bool {
        get {
            storage.get(for: .initialConsentDialogWasShown) ?? false
        }
        set {
            storage.store(newValue, for: .initialConsentDialogWasShown)
        }
    }

    init(appConfiguration: Configuration = AppConfiguration.shared,
         attributionTrackingService: AttributionTrackingApplicationServiceType = resolve(),
         consentChangeListeners: [ConsentChangeListener], storage: Storage = resolve(tag: .default)) {
        self.configuration = appConfiguration
        self.consentChangeListeners = consentChangeListeners
        self.storage = storage
    }

    private func registerNotifications() {
        authorizationObserver = NotificationCenter.default
            .observe(for: AuthorizationDidChangeNotification.self,
                     object: nil,
                     queue: .main) { [weak self] notification in
                if notification.newValue == nil {
                    self?.reset()
                }
            }
    }

    func application(_ application: UIApplicationType,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerNotifications()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplicationType) {
        showConsentDialogIfNeeded()
    }

    func showConsentDialogIfNeeded() {
        guard configuration.isConsentDialogEnabled else { return }
        configureUsercentrics()
        UsercentricsCore.isReady { [weak self] status in
            guard let self = self else { return }
            if status.shouldCollectConsent {
                // WORKAROUND:
                // UserCentrics crashes with an unhandled exception (that bubbles up from its Cotlin compatibility layer)
                // in case any attempt is made to show the UI too early
                // "Too early" meaning: Any time before this "isReady" callback was invoked
                // Turns out this still seems to be "too early" often times
                // Hence we add another thread switch here, which seems to help for now.
                // Fingers crossed.
                DispatchQueue.main.async {
                    self.showConsentDialog()
                }
            } else {
                self.applyConsent(with: status.consents)
                self.completion?(false)
                self.monitor.info("Consent information were provided before. Just applied it.", context: .consent)
            }
        } onFailure: { [weak self] error in
            self?.completion?(false)
            self?.monitor.error(error, context: .consent)
        }
    }

    func showConsentSettings() {
        guard configuration.isConsentDialogEnabled else { return }
        guard let hostViewController = UIViewController.topMostViewController?.parent as? UINavigationController else {
            monitor.error("No host view controller to display the consent dialog over", context: .consent)
            return
        }

        let banner = UsercentricsBanner(bannerSettings: styleSettings)
        banner.showSecondLayer(hostView: hostViewController) { [weak self] response in
            self?.applyConsent(with: response.consents)
        }
    }

    func reset() {
        initialConsentDialogWasShown = false
        UsercentricsCore.shared.clearUserSession(onSuccess: { _ in
        }, onError: {  [weak self] error in
            self?.monitor.error(error, context: .consent)
        })
    }

    private func configureUsercentrics() {
        let loggerLevel: UsercentricsLoggerLevel
        #if DEBUG || QA
            loggerLevel = .debug
        #else
            loggerLevel = .none
        #endif

        let defaultLanguage: String
        switch configuration.appVariant {
        case .knowledge: defaultLanguage = "en-us"
        case .wissen: defaultLanguage = "de"
        }

        let options = UsercentricsOptions(settingsId: configuration.usercentricsSettingsId)
        options.defaultLanguage = defaultLanguage
        options.loggerLevel = loggerLevel
        UsercentricsCore.configure(options: options)
    }

    private var isPresenting = false

    private func showConsentDialog() {
        guard configuration.isConsentDialogEnabled else { return }

        if isPresenting == false {
            guard let hostViewController = UIViewController.topMostViewController?.parent as? UINavigationController else {
                monitor.error("No host view controller to display the consent dialog over", context: .consent)
                return
            }

            let banner = UsercentricsBanner(bannerSettings: styleSettings)
            banner.showFirstLayer(hostView: hostViewController) { [weak self] response in
                self?.applyConsent(with: response.consents)
                self?.completion?(true)
                self?.isPresenting = false
            }
            isPresenting = true
        }

        // This is only a flag and via other logic elsewehere in the app
        initialConsentDialogWasShown = true
    }

    private var styleSettings: BannerSettings {
        let acceptAllButton = ButtonSettings(type: .acceptAll, backgroundColor: .backgroundAccent)
        let denyAllButton = ButtonSettings(type: .denyAll, backgroundColor: .backgroundAccent)
        let saveButton = ButtonSettings(type: .save, textColor: .textOnAccent, backgroundColor: .backgroundTransparentSelected)
        let buttonRow = ButtonLayout.row(buttons: [denyAllButton, acceptAllButton])
        let buttonGrid = ButtonLayout.grid(buttons: [[denyAllButton, acceptAllButton], [saveButton]])

        let firstLayer = FirstLayerStyleSettings(layout: .popup(position: .bottom),
                                                 buttonLayout: buttonRow,
                                                 backgroundColor: .canvas)

        let secondLayer = SecondLayerStyleSettings(buttonLayout: buttonGrid)

        let styleSettings = GeneralStyleSettings(textColor: .textPrimary,
                                                 layerBackgroundColor: .canvas,
                                                 layerBackgroundSecondaryColor: .canvas,
                                                 linkColor: .textAccent,
                                                 tabColor: .backgroundAccent,
                                                 bordersColor: .borderPrimary,
                                                 toggleStyleSettings: ToggleStyleSettings(activeBackgroundColor: .backgroundAccent))

        let settings = BannerSettings(generalStyleSettings: styleSettings,
                                      firstLayerStyleSettings: firstLayer,
                                      secondLayerStyleSettings: secondLayer)
        return settings
    }

    func setViewDismissalCompletion(completion: ((Bool) -> Void)?) {
        self.completion = completion
    }

    private func applyConsent(with consents: [UsercentricsServiceConsent]) {
        // The system tracking consent dialog must always be shown in US builds
        // Hence we do this no matter what the user selected via UserCentrics
        // Usercentrics does only show the "system tracking dialog" in case the user opts in to tracking
        // If he does not: this piece of code will show the "system tracking dialog" anyways for US builds
        // Also see here: https://miamed.atlassian.net/browse/PHEX-1315
        if configuration.appVariant == .knowledge, ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
                self?.handleConsents(consents)
            }
            return
        }

        handleConsents(consents)
    }

    private func handleConsents(_ consents: [UsercentricsServiceConsent],
                                status: ATTrackingManager.AuthorizationStatus? = ATTrackingManager.trackingAuthorizationStatus) {
        // All of out tracking is "required for technical reasons" - except "adjust"
        // We do not do "adjust" in case the user declined in either "usercentrics" or the "system tracking dialog"
        let hasAdjustConsent = consents.contains {
            $0.templateId == configuration.userCentricsAdjustTemplateID && $0.type == .explicit_ && $0.status
        }
        let hasSystemTrackingConsent = status == .authorized

        let adjustIsEnabled: Bool
        switch configuration.appVariant {
        case .knowledge:
            // The user will have seen the "system tracking dialog" already in US builds
            adjustIsEnabled = hasAdjustConsent && hasSystemTrackingConsent
        case .wissen:
            // "status" might be .notDeterminded at this point cause the user has not seen the "system tracking dialog"
            // "adjust" will bring up the system dialog itself in case the user opted in via "usercentrics"
            // To make this happen we need to enable adjust in case the user opted in (ignoring the  system consent status)
            adjustIsEnabled = hasAdjustConsent
        }

        consentChangeListeners.forEach { $0.consentDidChange([.adjust: adjustIsEnabled]) }
    }
}
