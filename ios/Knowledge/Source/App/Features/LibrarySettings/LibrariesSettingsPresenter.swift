//
//  LibrariesSettingsPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 17.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

protocol LibrariesSettingsPresenterType: AnyObject {
    var view: LibrariesSettingsViewType? { get set }
    func updateLibrary()
    func didChangeIsAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool)
    func updatePharma()
    func didChangePharmaIsAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool)
    func presentDeletePharmaDatabaseAlert()

    /// This method is exposed for testing reasons.
    ///
    /// We do not call this method directly. We call it from `presentDeletePharmaDatabaseAlert()` method.
    func deletePharmaDatabase()
}

final class LibrariesSettingsPresenter: LibrariesSettingsPresenterType {

    private let libraryRepository: LibraryRepositoryType
    private let libraryUpdater: LibraryUpdaterType
    private var pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType?
    private let trackingProvider: TrackingType
    private let monitor: Monitoring = resolve()

    private var libraryUpdaterStateDidChangeObserver: NSObjectProtocol?
    private var pharmaUpdaterStateDidChangeObserver: NSObjectProtocol?

    init(libraryRepository: LibraryRepositoryType = resolve(), libraryUpdater: LibraryUpdaterType, pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType? = resolve(), trackingProvider: TrackingType = resolve()) {
        self.libraryRepository = libraryRepository
        self.libraryUpdater = libraryUpdater
        self.pharmaDatabaseApplicationService = pharmaDatabaseApplicationService
        self.trackingProvider = trackingProvider

        libraryUpdaterStateDidChangeObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] _ in
            self?.updateLibraryView()
        }

        pharmaUpdaterStateDidChangeObserver = NotificationCenter.default.observe(for: PharmaOfflineDatabaseApplicationServiceDidChangeStateNotification.self, object: pharmaDatabaseApplicationService, queue: .main) { [weak self] _ in
            self?.updatePharmaView()
        }
    }

    weak var view: LibrariesSettingsViewType? {
        didSet {
            updateLibraryView()
            view?.setIsLibraryAutoUpdateEnabled(libraryUpdater.isBackgroundUpdatesEnabled)
            libraryUpdater.initiateUpdate(isUserTriggered: false)

            // pharmaDatabaseApplicationSerive is nil in US builds
            if  let pharmaDatabaseApplicationService = self.pharmaDatabaseApplicationService {
                updatePharmaView()
                view?.setIsPharmaAutoUpdateEnabled(pharmaDatabaseApplicationService.isBackgroundUpdatesEnabled)
                try? pharmaDatabaseApplicationService.startAutomaticUpdate()
            } else {
                // Remove Pharma database update data in US builds and for users with disabled pharma feature flag
                view?.removePharmaData()
            }
        }
    }

    private func updateLibraryView() {
        switch libraryUpdater.state {
        case .upToDate: view?.setState(.library(.upToDate))
        case .downloading(_, let progress, _): view?.setState(.library(.downloading(progress)))
        case .checking: view?.setState(.library(.checking))
        case .installing: view?.setState(.library(.installing))
        case .failed(let update, let error):
            switch error {
            case .backgroundUpdatesNotAllowed: view?.setState(.library(.outdated(update.size, isPharmaDatabaseAlreadyInstalled: nil)))
            default: view?.setState(.library(.failed(update.size, L10n.LibrarySettings.UpdateFailed.title, updateErrorString(for: error))))
            }
        }
    }

    private func updatePharmaView() {
        guard let state = pharmaDatabaseApplicationService?.state else { return }

        switch state {
        case .idle(let error, let availableUpdate, let type):
            if type == .automatic, availableUpdate == nil {
                view?.setState(.pharma(.upToDate))
            } else {
                if let error = error, let availableUpdate = availableUpdate {
                    switch error {
                    case .updateNotAllowed: view?.setState(.pharma(.outdated(availableUpdate.size, isPharmaDatabaseAlreadyInstalled: true)))
                    case .storageExceeded: view?.setState(.pharma(.failed(availableUpdate.size, L10n.LibrarySettings.UpdateFailed.title, L10n.LibrarySettings.UpdateFailed.LackOfStorage.description)))
                    case .noDatabaseToUpdate, .canceled:
                        view?.setState(.pharma(.outdated(availableUpdate.size, isPharmaDatabaseAlreadyInstalled: false)))
                        view?.setPharmaDatabaseDeletable(pharmaDatabaseApplicationService?.pharmaDatabase != nil)
                    default: view?.setState(.pharma(.failed(availableUpdate.size, L10n.LibrarySettings.UpdateFailed.title, L10n.LibrarySettings.Pharma.UpdateFailed.SomethingWentWrong.description)))
                    }
                } else if error != nil {
                    view?.setState(.pharma(.failed(nil, L10n.LibrarySettings.UpdateFailed.title, L10n.LibrarySettings.Pharma.UpdateFailed.SomethingWentWrong.description)))
                } else if let availableUpdate = availableUpdate {
                    view?.setState(.pharma(.outdated(availableUpdate.size, isPharmaDatabaseAlreadyInstalled: false)))
                } else {
                    view?.setState(.pharma(.upToDate))
                }
            }
            view?.setPharmaDatabaseDeletable(pharmaDatabaseApplicationService?.pharmaDatabase != nil)
        case .checking:
            view?.setState(.pharma(.checking))
        case .downloading(_, let progress):
            view?.setState(.pharma(.downloading(progress)))
            view?.setPharmaDatabaseDeletable(true)
        case .installing:
            view?.setState(.pharma(.installing))
            view?.setPharmaDatabaseDeletable(true)
        }
    }

    private func updateErrorString(for error: LibraryUpdateError) -> String {
        switch error {
        case .storageExceeded:
            return L10n.LibrarySettings.UpdateFailed.LackOfStorage.description
        default:
            return L10n.LibrarySettings.UpdateFailed.SomethingWentWrong.description
        }
    }

    func updateLibrary() {
        libraryUpdater.initiateUpdate(isUserTriggered: true)
    }

    func didChangeIsAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool) {
        libraryUpdater.isBackgroundUpdatesEnabled = isAutoUpdateEnabled
    }

    func updatePharma() {
        do {
            try pharmaDatabaseApplicationService?.startManualUpdate()
        } catch {
            monitor.error(error, context: .library)
        }
    }

    func didChangePharmaIsAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool) {
        pharmaDatabaseApplicationService?.isBackgroundUpdatesEnabled = isAutoUpdateEnabled
        do {
            if isAutoUpdateEnabled {
                try pharmaDatabaseApplicationService?.startAutomaticUpdate()
            }
        } catch {
            monitor.error(error, context: .library)
        }
    }

    func presentDeletePharmaDatabaseAlert() {
        self.trackingProvider.track(.pharmaOfflineDeleteAlertShown)

        let cancelAction = MessageAction(title: L10n.LibrarySettings.Pharma.DeleteConfirmationAlert.CancelAction.title, style: .normal) { [weak self] in
            guard let self = self else { return true }
            self.trackingProvider.track(.pharmaOfflineDeleteDeclined)
            return true
        }
        let confirmAction = MessageAction(title: L10n.LibrarySettings.Pharma.DeleteConfirmationAlert.ConfirmAction.title, style: .primary) { [weak self] in
            guard let self = self else { return true }
            self.deletePharmaDatabase()
            return true
        }
        let message = PresentableMessage(title: L10n.LibrarySettings.Pharma.DeleteConfirmationAlert.title, description: L10n.LibrarySettings.Pharma.DeleteConfirmationAlert.message, logLevel: .info)

        view?.presentMessage(message, actions: [cancelAction, confirmAction])
    }

    func deletePharmaDatabase() {
        do {
            try pharmaDatabaseApplicationService?.deleteDatabase()
        } catch {
            // Its enough to just track this error, any relevant error will be
            // reflected in the PharmaDatabaseApplicationService's state
            monitor.error(error, context: .library)
        }
        pharmaDatabaseApplicationService?.isBackgroundUpdatesEnabled = false
        view?.setIsPharmaAutoUpdateEnabled(false)
    }
}
