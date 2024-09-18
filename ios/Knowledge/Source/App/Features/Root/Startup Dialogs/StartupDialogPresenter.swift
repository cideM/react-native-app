//
//  StartupDialogPresenter.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 16.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

protocol StartupDialogPresenterType: AnyObject {
    func showFirstDialog()
    func showNextDialog()
}

final class StartupDialogPresenter: StartupDialogPresenterType {

    enum StartupDialogType {
        case consent
        case shop
        case none

        func next() -> StartupDialogType {
            switch self {
            case .consent: return .shop
            case .shop: return .none
            default: return .none
            }
        }
    }

    private weak var coordinator: StartupDialogCoordinatorType?
    private let consentApplicationService: ConsentApplicationServiceType
    private let trackingProvider: TrackingType
    private var storage: Storage
    private let appConfiguration: Configuration
    private let remoteConfigRepository: RemoteConfigRepositoryType

    var currentDialog = StartupDialogType.consent

    init(
        coordinator: StartupDialogCoordinatorType,
        consentApplicationService: ConsentApplicationServiceType = resolve(),
        trackingProvider: TrackingType = resolve(),
        storage: Storage = resolve(tag: .default),
        appConfiguration: Configuration = AppConfiguration.shared,
        remoteConfigRepository: RemoteConfigRepositoryType = resolve()
    ) {
        self.coordinator = coordinator
        self.consentApplicationService = consentApplicationService
        self.trackingProvider = trackingProvider
        self.storage = storage
        self.appConfiguration = appConfiguration
        self.remoteConfigRepository = remoteConfigRepository
    }

    func showFirstDialog() {
        self.show(dialog: .consent)
    }

    func showNextDialog() {
        currentDialog = currentDialog.next()
        show(dialog: currentDialog)
    }

    private func show(dialog: StartupDialogType) {
        switch currentDialog {
        case .consent:
            consentApplicationService.setViewDismissalCompletion { [weak self] _ in
                self?.consentApplicationService.setViewDismissalCompletion(completion: nil)
                self?.showNextDialog()
            }
            consentApplicationService.showConsentDialogIfNeeded()
        case .shop:
            let didPresentStoreAfterSignup = storage.get(for: StorageKey.didPresentStoreAfterSignup) ?? true
            storage.store(true, for: StorageKey.didPresentStoreAfterSignup)
            if !didPresentStoreAfterSignup {
                coordinator?.showStore { [weak self] in
                    self?.showNextDialog()
                }
            } else {
                self.showNextDialog()
            }
        case .none:
            coordinator?.stop(animated: false)
        }
    }
}
