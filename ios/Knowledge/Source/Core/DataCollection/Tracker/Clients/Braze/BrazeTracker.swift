//
//  BrazeTracker.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 21.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

protocol BrazeTrackingType: TrackingType {
}

class BrazeTracker: BrazeTrackingType {

    private struct EventKeys {
        static let email = "email"
        static let stage = "stage"
        static let region = "region"
    }

    private struct EventName {
        static let registerSuccess = "register_success"
        static let noAccessBuyLicense = "no_access_buy_license"
    }

    private let appConfiguration: Configuration
    private let authorizatuionRepository: AuthorizationRepositoryType
    private let service: BrazeApplicationServiceType

    @Inject private var remoteConfigRepository: RemoteConfigRepositoryType

    init(appConfiguration: Configuration = AppConfiguration.shared,
         authenticationRepository: AuthorizationRepositoryType = resolve(),
         brazeApplicationService: BrazeApplicationServiceType = resolve()) {
        self.appConfiguration = appConfiguration
        self.authorizatuionRepository = authenticationRepository
        self.service = brazeApplicationService
    }

    func track(_ event: Tracker.Event) {
        guard
            remoteConfigRepository.brazeEnabled,
            let auth = authorizatuionRepository.authorization,
            let email = auth.user.email
        else { return }
        let xid = auth.user.identifier.value

        switch event {
        case .signupAndLogin(let event):
            switch event {
            case .loginCompleted:
                guard service.isLoginTrackingNeeded else { return }
                service.identify(id: xid, email: email)

            case .registerSuccess(let email, _, let stage):
                service.identify(id: xid, email: email)

                let stage = BrazeApplicationService.map(userStage: stage)
                let region = BrazeApplicationService.map(variant: appConfiguration.appVariant)

                service.client?.user.setCustomAttribute(key: EventKeys.region, value: region.trackingProperty())
                service.client?.user.setCustomAttribute(key: EventKeys.stage, value: stage.trackingProperty())

                service.client?.logCustomEvent(name: EventName.registerSuccess, properties: [
                    EventKeys.email: email,
                    EventKeys.region: region.trackingProperty(),
                    EventKeys.stage: stage.trackingProperty()
                ] as [String: Any])

            default:
                break
            }

        case .inAppPurchase(let event):
            switch event {
            case .noAccessBuyLicense:
                service.client?.logCustomEvent(name: EventName.noAccessBuyLicense, properties: [
                    EventKeys.email: email
                ])
            default:
                break
            }

        default:
            break
        }
    }

    func set(_ userTraits: [UserTraits]) {
        // Not usage via Braze ...
    }

    func update(_ userTraits: UserTraits) {
        // Not usage via Braze ...
    }
}
