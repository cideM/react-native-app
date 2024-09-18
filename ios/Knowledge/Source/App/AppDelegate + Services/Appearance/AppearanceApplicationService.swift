//
//  AppearanceApplicationService.swift
//  Knowledge
//
//  Created by AMBOSS  VSS on 12.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import DesignSystem
import Common
import Darwin

/// @mockable
protocol AppearanceApplicationServiceType: ApplicationService {
    var userCanChangeInterfaceStyle: Bool { get }
}

internal class AppearanceApplicationService: AppearanceApplicationServiceType {

    static func applyAppearance() {

        DesignSystem.initialize()
        applyUINavigationBarAppearance()
        applyUITabBarAppearance()
        applyUITabBarItemAppearance()
        applyUITableViewAppearance()
        applyUITextFieldAppearance()
        applyUITextViewAppearance()
        applyUISearchBarAppearance()
        applyUISegmentedControlAppearance()
    }

    private let featureFlagRepository: FeatureFlagRepositoryType
    private let configuration: Configuration
    private let libraryRepository: LibraryRepositoryType
    private let deviceSettingsRepository: DeviceSettingsRepositoryType
    private var userInterfaceStyleObserver: NSObjectProtocol?

    init(featureFlagRepository: FeatureFlagRepositoryType = resolve(),
         configuration: Configuration = AppConfiguration.shared,
         libraryRepository: LibraryRepositoryType = resolve(),
         deviceSettingsRepository: DeviceSettingsRepositoryType = resolve()) {
        self.featureFlagRepository = featureFlagRepository
        self.configuration = configuration
        self.libraryRepository = libraryRepository
        self.deviceSettingsRepository = deviceSettingsRepository
        self.registerNotifactions()
    }

    func application(_ application: UIApplicationType,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        updateUserInterfaceStyle(style: deviceSettingsRepository.currentUserInterfaceStyle, in: application.keyWindow, animated: false)
        application.keyWindow?.tintColor = ThemeManager.currentTheme.tintColor
        AppearanceApplicationService.applyAppearance()

        application.keyWindow?.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)

        return true
    }

    var userCanChangeInterfaceStyle: Bool {
        libraryRepository.library.metadata.isDarkModeSupported
    }

    private func updateUserInterfaceStyle(style: UIUserInterfaceStyle, in window: UIWindow?, animated: Bool) {
        guard let window else { return }

        // If user can't change to dark mode, force light mode instead
        let overrideStyle: UIUserInterfaceStyle = userCanChangeInterfaceStyle ? style : .light
        if animated {
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.overrideUserInterfaceStyle = overrideStyle
            })
        } else {
            window.overrideUserInterfaceStyle = overrideStyle
        }
    }

    private func registerNotifactions() {
        self.userInterfaceStyleObserver = NotificationCenter.default.observe(
            for: UserInterfaceStyleChangedNotification.self,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.updateUserInterfaceStyle(style: notification.style,
                                               in: UIApplication.keyWindow,
                                               animated: true)
        }
    }

    private static func applyUINavigationBarAppearance() {
        let backImage = Common.Asset.chevronLeft.image
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = .backgroundAccent
        UINavigationBar.appearance().tintColor = .iconOnAccent
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = ThemeManager.currentTheme.tintColor

        let standard = UINavigationBarAppearance()
        standard.configureWithOpaqueBackground()
        standard.backgroundColor = .backgroundAccent
        standard.titleTextAttributes = ThemeManager.currentTheme.navigationBarTitleTextAttributes
        standard.largeTitleTextAttributes = ThemeManager.currentTheme.navigationBarLargeTitleTextAttributes

        standard.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        UINavigationBar.appearance().standardAppearance = standard
        UINavigationBar.appearance().scrollEdgeAppearance = standard
        UINavigationBar.appearance().compactAppearance = standard

        UISegmentedControl.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .backgroundAccent
    }

    private static func applyUITableViewAppearance() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }

    private static func applyUITabBarAppearance() {
        if #available(iOS 15, *) {
            let standard = UITabBarAppearance()
            standard.configureWithOpaqueBackground()
            standard.backgroundColor = .backgroundPrimary
            UITabBar.appearance().standardAppearance = standard
            UITabBar.appearance().scrollEdgeAppearance = standard
        }

        UITabBar.appearance().tintColor = .textAccent
    }

    private static func applyUITabBarItemAppearance() {
         UITabBarItem.appearance().setTitleTextAttributes(ThemeManager.currentTheme.tabBarSelectedItemTextAttributes, for: .selected)
    }

    private static func applyUITextFieldAppearance() {
        UITextField.appearance().defaultTextAttributes = ThemeManager.currentTheme.textFieldTextAttributes
    }

    private static func applyUITextViewAppearance() {
        UITextView.appearance().linkTextAttributes = ThemeManager.currentTheme.textViewLinkTextAttributes
    }

    private static func applyUISearchBarAppearance() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = ThemeManager.currentTheme.searchTextFieldTextAttributes
    }

    private static func applyUISegmentedControlAppearance() {
        UISegmentedControl.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        UISegmentedControl.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = ThemeManager.currentTheme.tintColor
    }
}
