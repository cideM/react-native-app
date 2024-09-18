//
//  ZendeskApplicationService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 14.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import CommonUISDK

import Domain
import Networking
import SupportSDK
import UIKit
import ZendeskCoreSDK

final class ZendeskApplicationService {
    weak var delegate: SupportApplicationServiceDelegate?
    private var authorizationDidChangeObserver: NSObjectProtocol?
    private var requestSubmissionSuccessObserver: NSObjectProtocol?
    private lazy var helpCenterConfiguration: HelpCenterUiConfiguration = {
        let helpCenterUiConfiguration = HelpCenterUiConfiguration()
        helpCenterUiConfiguration.labels = ["iOS-whitelist"]
        return helpCenterUiConfiguration
    }()

    init(authorizationRepository: AuthorizationRepositoryType = resolve()) {

        Zendesk.initialize(appId: "cfee66ddd7bb131beb6327916fccdded16f9e22844531474",
                           clientId: "mobile_sdk_client_604bd0b6b380d95df4cd",
                           zendeskUrl: "https://amboss.zendesk.com")
        Support.initialize(withZendesk: Zendesk.instance)
        switch AppConfiguration.shared.appVariant {
        case .knowledge: Support.instance?.helpCenterLocaleOverride = "en-us"
        case .wissen: Support.instance?.helpCenterLocaleOverride = "de"
        }
        CommonTheme.currentTheme.primaryColor = ThemeManager.currentTheme.tintColor

        if let authorization = authorizationRepository.authorization {
            configure(with: authorization)
        }

        authorizationDidChangeObserver = NotificationCenter.default.observe(for: AuthorizationDidChangeNotification.self, object: nil, queue: .main) { [weak self] change in
            guard let authorization = change.newValue else { return }
            self?.configure(with: authorization)
        }

        requestSubmissionSuccessObserver = NotificationCenter.default.observe(forName: NSNotification.Name(rawValue: ZDKAPI_RequestSubmissionSuccess), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let request = (userInfo["request"] as? ZDKRequest)
            else { return }
            self.delegate?.feedbackSubmitted(feedbackText: request.requestDescription)
        }
    }

    private func configure(with authorization: Authorization) {
        let userFullName = [authorization.user.firstName, authorization.user.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        Zendesk.instance?.setIdentity(Identity.createAnonymous(name: userFullName, email: authorization.user.email))
    }

    private func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)

        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ThemeManager.currentTheme.tintColor,
            .font: Font.bold.font(withSize: 16)
        ]

        let standard = UINavigationBarAppearance()
        standard.titleTextAttributes = titleTextAttributes

        navigationController.navigationBar.standardAppearance = standard
        navigationController.navigationBar.scrollEdgeAppearance = standard
        navigationController.navigationBar.compactAppearance = standard
        navigationController.navigationBar.tintColor = ThemeManager.currentTheme.tintColor
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.barTintColor = ThemeManager.currentTheme.barTintColor
        navigationController.navigationItem.searchController?.searchBar.tintColor = ThemeManager.currentTheme.tintColor

        return navigationController
    }
}

extension ZendeskApplicationService: SupportApplicationService {

    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func showRequestViewController(on viewController: UIViewController, requestType: SupportRequestConfiguration) {
        let requestViewController = RequestUi.buildRequestUi(with: [requestType.requestConfiguration])
        viewController.present(navigationController(with: requestViewController), animated: true)
    }

    func showHelpCenterOverviewViewController(on viewController: UIViewController, requestType: SupportRequestConfiguration) {
        let helpCenterViewController = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [helpCenterConfiguration, requestType.requestConfiguration])
        viewController.present(navigationController(with: helpCenterViewController), animated: true)
    }
}

private extension SupportRequestConfiguration.Field {
    var zendeskId: Int64 {
        switch self {
        case .appVersion: return 360023881451
        case .appOSVersion: return 360023866332
        case .appDeviceId: return 360023881471
        case .appDeviceName: return 360023881691
        case .appLibraryVersionDate: return 360023866512
        case .pharmaCard: return 360027329431
        case .searchQuery: return 360027329451
        case .agent: return 360048984672
        case .drug: return 360048984692
        }
    }
}

private extension SupportRequestConfiguration {

    private var zendeskTicketSubject: String {
        switch self {
        case .pharma: return "Pharma Card feedback from iOS"
        case .monograph: return "Monograph feedback from iOS"
        case .standard: return ""
        }
    }
    private var zendeskFormID: NSNumber {
        switch self {
        case .pharma, .monograph: return NSNumber(360000669911)
        case .standard: return NSNumber(360000558592)
        }
    }
    private var zendeskTags: [String] {
        let appName: String
        switch AppConfiguration.shared.appVariant {
        case .wissen: appName = "Wissen"
        case .knowledge: appName = "Knowledge"
        }

        switch self {
        case .pharma, .monograph:
            return ["ios", "pharma_card", appName]
        case .standard: return ["ios", appName]
        }
    }
    private var zendeskCustomFields: [CustomField] {
        switch self {
        case .pharma(_, let application, let device, let deviceId, let libraryVersionDate, let agentId, let drugId, let lastPharmaSearchQuery):
            return [
                CustomField(fieldId: Field.appVersion.zendeskId, value: application.version),
                CustomField(fieldId: Field.appOSVersion.zendeskId, value: device.osVersion),
                CustomField(fieldId: Field.appDeviceName.zendeskId, value: device.humanReadablePlatform ?? device.platform),
                CustomField(fieldId: Field.appLibraryVersionDate.zendeskId, value: libraryVersionDate),
                CustomField(fieldId: Field.appDeviceId.zendeskId, value: deviceId),
                CustomField(fieldId: Field.searchQuery.zendeskId, value: lastPharmaSearchQuery),
                CustomField(fieldId: Field.agent.zendeskId, value: agentId),
                CustomField(fieldId: Field.drug.zendeskId, value: drugId)
            ]
        case .monograph(_, let application, let device, let deviceId, let libraryVersionDate, let monographId, let lastMonographSearchQuery):
            return [
                CustomField(fieldId: Field.appVersion.zendeskId, value: application.version),
                CustomField(fieldId: Field.appOSVersion.zendeskId, value: device.osVersion),
                CustomField(fieldId: Field.appDeviceName.zendeskId, value: device.humanReadablePlatform ?? device.platform),
                CustomField(fieldId: Field.appLibraryVersionDate.zendeskId, value: libraryVersionDate),
                CustomField(fieldId: Field.appDeviceId.zendeskId, value: deviceId),
                CustomField(fieldId: Field.searchQuery.zendeskId, value: lastMonographSearchQuery),
                CustomField(fieldId: Field.pharmaCard.zendeskId, value: monographId)
            ]
        case .standard(_, let application, let device, let deviceId, let libraryVersionDate):
            return [
                CustomField(fieldId: Field.appVersion.zendeskId, value: application.version),
                CustomField(fieldId: Field.appOSVersion.zendeskId, value: device.osVersion),
                CustomField(fieldId: Field.appDeviceName.zendeskId, value: device.humanReadablePlatform ?? device.platform),
                CustomField(fieldId: Field.appLibraryVersionDate.zendeskId, value: libraryVersionDate),
                CustomField(fieldId: Field.appDeviceId.zendeskId, value: deviceId)
            ]
        }
    }

    var requestConfiguration: RequestUiConfiguration {
        let requestConfiguration = RequestUiConfiguration()
        requestConfiguration.subject = zendeskTicketSubject
        requestConfiguration.customFields = zendeskCustomFields
        requestConfiguration.ticketFormID = zendeskFormID

        #if DEBUG || QA
        requestConfiguration.tags = zendeskTags + ["eng_testing"]
        #else
        requestConfiguration.tags = zendeskTags
        #endif

        return requestConfiguration
    }
}
