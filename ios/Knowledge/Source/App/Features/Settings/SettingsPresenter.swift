//
//  SettingsPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 24.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

protocol SettingsPresenterType: AnyObject {
    var view: SettingsViewType? { get set }
    func didSelect(item: Settings.Item)
    func viewDidAppear()
}

final class SettingsPresenter: SettingsPresenterType {
    private let coordinator: SettingsCoordinatorType
    private let libraryUpdater: LibraryUpdaterType
    private let pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType?
    private let userDataRepository: UserDataRepositoryType
    private let analyticsTracker: TrackingType
    private let featureFlagRepository: FeatureFlagRepositoryType
    private let appConfiguration: Configuration

    private var userStageObserver: NSObjectProtocol?
    private var studyObjectiveObserver: NSObjectProtocol?
    private var libraryUpdaterStateObserver: NSObjectProtocol?
    private var pharmaUpdaterStateObserver: NSObjectProtocol?
    private var userInterfaceStyleObserver: NSObjectProtocol?
    private let authorizationRepository: AuthorizationRepositoryType
    private let deviceSettingsRepository: DeviceSettingsRepositoryType
    private let appearanceService: AppearanceApplicationServiceType

    init(coordinator: SettingsCoordinatorType, libraryUpdater: LibraryUpdaterType, pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType? = resolve(), userDataRepositoryType: UserDataRepositoryType, analyticsTracker: TrackingType = resolve(), featureFlagRepository: FeatureFlagRepositoryType = resolve(), appConfiguration: Configuration = AppConfiguration.shared, authorizationRepository: AuthorizationRepositoryType, deviceSettingsRepository: DeviceSettingsRepositoryType = resolve(), appearanceService: AppearanceApplicationServiceType = resolve()) {
        self.coordinator = coordinator
        self.libraryUpdater = libraryUpdater
        self.pharmaDatabaseApplicationService = pharmaDatabaseApplicationService
        self.userDataRepository = userDataRepositoryType
        self.analyticsTracker = analyticsTracker
        self.featureFlagRepository = featureFlagRepository
        self.appConfiguration = appConfiguration
        self.authorizationRepository = authorizationRepository
        self.deviceSettingsRepository = deviceSettingsRepository
        self.appearanceService = appearanceService
    }

    weak var view: SettingsViewType? {
        didSet {
            view?.set(sections: viewData())
            libraryUpdaterStateObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] _ in
                self?.reloadViewData()
            }
            pharmaUpdaterStateObserver = NotificationCenter.default.observe(for: PharmaOfflineDatabaseApplicationServiceDidChangeStateNotification.self, object: pharmaDatabaseApplicationService, queue: .main) { [weak self] _ in
                self?.reloadViewData()
            }
            userStageObserver = NotificationCenter.default.observe(for: UserStageDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] _ in
                self?.reloadViewData()
            }
            studyObjectiveObserver = NotificationCenter.default.observe(for: StudyObjectiveDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] _ in
                self?.reloadViewData()
            }
            userInterfaceStyleObserver = NotificationCenter.default.observe(for: UserInterfaceStyleChangedNotification.self, object: nil, queue: .main) { [weak self] _ in
                    self?.reloadViewData()
            }
        }
    }

    func didSelect(item: Settings.Item) {
        coordinator.goToViewController(of: item.itemType, animated: true)
    }

    func viewDidAppear() {
        analyticsTracker.track(.settingsOpened)
    }
}

extension SettingsPresenter {

    private func viewData() -> [Settings.Section] {
        // Account Section
        let accountItem = Settings.Item(title: authorizationRepository.authorization?.user.email ?? L10n.AccountSettings.title, subtitle: "", hasChevron: true, subtitleWarning: false, itemType: .accountSettings)

        let userStageItem = Settings.Item(title: L10n.UserStage.title, subtitle: userDataRepository.userStage.map { localizedString(for: $0 ) } ?? "", hasChevron: true, subtitleWarning: false, itemType: .userstage)
        let storeItem = Settings.Item(title: L10n.Iap.Settings.Store.title, subtitle: "", hasChevron: true, subtitleWarning: false, itemType: .shop)

        var accountSectionItems: [Settings.Item] = []
        if appConfiguration.hasStudyObjective {
            let studyObjectiveItem = Settings.Item(title: L10n.StudyObjective.title, subtitle: userDataRepository.studyObjective?.name ?? "", hasChevron: true, subtitleWarning: false, itemType: .studyobjective)
            accountSectionItems = [accountItem, userStageItem, studyObjectiveItem, storeItem]
        } else {
            accountSectionItems = [accountItem, userStageItem, storeItem]
        }

        // Procuct keys are currently not supported in DE cause apple rejected this feature
        // See here for more context: https://miamed.atlassian.net/browse/PHEX-1733
        var isDEBUGorQA = false
        #if DEBUG || QA
        isDEBUGorQA = true
        #endif
        if appConfiguration.appVariant != .wissen || isDEBUGorQA {
            let redeemCodeItem = Settings.Item(title: L10n.RedeemCode.title, subtitle: "", hasChevron: true, subtitleWarning: false, itemType: .redeemCode())
            accountSectionItems.append(redeemCodeItem)
        }

        let accountSection = Settings.Section(title: L10n.AccountSettings.Account.title, items: accountSectionItems, footer: "")

        // Update Section
        let libraryItem = self.libraryItem(for: libraryUpdater.state, pharmaState: pharmaDatabaseApplicationService?.state)
        let updateSectionItems = [libraryItem]
        let updateSection = Settings.Section(title: L10n.LibrarySettings.update, items: updateSectionItems, footer: "")

        // App Settings Section
        let subtitle = appearanceService.userCanChangeInterfaceStyle ? deviceSettingsRepository.currentUserInterfaceStyle.title : ""
        let appearanceItem = Settings.Item(title: L10n.AppearanceSettings.title,
                                           subtitle: subtitle,
                                           hasChevron: true,
                                           subtitleWarning: false,
                                           itemType: .appearance)
        let appSettingsSectionItems = [appearanceItem]
        let appSettingsSection = Settings.Section(title: L10n.Settings.AppSettingsSection.title, items: appSettingsSectionItems, footer: "")

        // Support Section
        let helpCenterItem = Settings.Item(title: L10n.Settings.Support.HelpCenter.title, subtitle: "", hasChevron: false, subtitleWarning: false, itemType: .supportus)
        let supportSectionItems = [helpCenterItem]
        let supportSection = Settings.Section(title: L10n.Support.title, items: supportSectionItems, footer: "")

        // More Section
        let tryQBankItem = Settings.Item(title: L10n.Settings.More.Qbank.title, subtitle: "", hasChevron: false, subtitleWarning: false, itemType: .qbank)
        let aboutItem = Settings.Item(title: L10n.Settings.More.About.title, subtitle: "", hasChevron: true, subtitleWarning: false, itemType: .about)
        let moreSectionItems = [tryQBankItem, aboutItem]
        let moreSection = Settings.Section(title: L10n.Settings.More.title, items: moreSectionItems, footer: "")

        // All Sections
        let sections = [accountSection, updateSection, appSettingsSection, supportSection, moreSection]

        return sections
    }

    private func reloadViewData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.set(sections: self.viewData())
        }
    }

    private func libraryItem(for state: LibraryUpdaterState, pharmaState: PharmaDatabaseApplicationServiceState?) -> Settings.Item {
        let title = pharmaState != nil ? L10n.Settings.Update.LibraryAndPharma.title : L10n.Library.title

        let library = state
        if let pharma = pharmaState { // <- pharma is only available in DE builds
            if library.isUpToDate && pharma.isUpToDate {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updated, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.hasUpdate || pharma.hasUpdate {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updateAvailableMessage, hasChevron: true, subtitleWarning: true, itemType: .library)
            } else if library.isChecking || pharma.isChecking {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.checkingForUpdateMessage, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.isProcessing || pharma.isProcessing {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updatingMessage, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.hasError || pharma.hasError {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updateFailed, hasChevron: true, subtitleWarning: true, itemType: .library)
            }

        // This can be deleted once us has a pharma library ...
        } else {
            if library.isUpToDate {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updated, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.hasUpdate {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updateAvailableMessage, hasChevron: true, subtitleWarning: true, itemType: .library)
            } else if library.isChecking {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.checkingForUpdateMessage, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.isProcessing {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updatingMessage, hasChevron: true, subtitleWarning: false, itemType: .library)
            } else if library.hasError {
                return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updateFailed, hasChevron: true, subtitleWarning: true, itemType: .library)
            }
        }

        // This should never be triggered, but it's here to please the compiler
        return Settings.Item(title: title, subtitle: L10n.LibrarySettings.updated, hasChevron: true, subtitleWarning: false, itemType: .library)
    }

    private func localizedString(for userStage: UserStage) -> String {
        switch userStage {
        case .physician: return L10n.UserStage.UserStagePhysician.title
        case .clinic: return L10n.UserStage.UserStageClinic.title
        case .preclinic: return L10n.UserStage.UserStagePreclinic.title
        }
    }
}

private extension PharmaDatabaseApplicationServiceState {

    var isChecking: Bool {
        switch self {
        case .checking: return true
        default: return false
        }
    }
    var isUpToDate: Bool {
        switch self {
        case .idle(_, let availableUpdate, _): return availableUpdate == nil
        default: return false
        }
    }
    var isProcessing: Bool {
        switch self {
        case .downloading, .installing: return true
        default: return false
        }
    }
    var hasError: Bool {
        switch self {
        case .idle(let error, _, _): return error != nil
        default: return false
        }
    }
    var hasUpdate: Bool {
        switch self {
        case .idle(_, let availableUpdate, _): return availableUpdate != nil
        default: return false
        }
    }
}

private extension LibraryUpdaterState {

    var isChecking: Bool {
        switch self {
        case .checking: return true
        default: return false
        }
    }
    var isUpToDate: Bool {
        switch self {
        case .upToDate: return true
        default: return false
        }
    }
    var isProcessing: Bool {
        switch self {
        case .downloading, .installing: return true
        default: return false
        }
    }
    var hasError: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
    var hasUpdate: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
}
