//
//  InAppPurchaseStorePresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 02.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import StoreKit
import Localization

/// @mockable
protocol InAppPurchaseStorePresenterType: AnyObject {
    var view: InAppPurchaseStoreViewType? { get set }
    func startPurchaseWasTapped()
    func restorePurchaseWasTapped()
    func linkPurchaseWasTapped()
    func cancelSubscriptionWasTapped()
    func contactSupportWasTapped()
    func retryWasTapped()
    func pageDidChange(_ page: Int)
}

final class InAppPurchaseStorePresenter: InAppPurchaseStorePresenterType {

    weak var view: InAppPurchaseStoreViewType? {
        didSet {
            view?.setLoading()
            inAppPurchaseApplicationService.updateStoreState()
            analyticsTracker.track(.iapStoreOpened)
        }
    }

    private let inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType
    private let coordinator: InAppPurchaseCoordinatorType
    private let analyticsTracker: TrackingType
    private var inAppPurchaseStateDidChangeNotification: NSObjectProtocol?
    private var didTrackStoreLoaded = false

    init(inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType, coordinator: InAppPurchaseCoordinatorType, analyticsTracker: TrackingType = resolve()) {
        self.inAppPurchaseApplicationService = inAppPurchaseApplicationService
        self.coordinator = coordinator
        self.analyticsTracker = analyticsTracker
        inAppPurchaseStateDidChangeNotification = NotificationCenter.default.observe(for: InAppPurchaseStateDidChangeNotification.self, object: inAppPurchaseApplicationService, queue: .main) { [weak self] change in
            guard let self = self else { return }
            let state = change.newValue
            switch state {
            case .loading:
                self.view?.setLoading()
            case .temporaryError, .permanentError:
                self.view?.showGenericError()
            case .readyToBuy(let product):
                let offer = self.offer(for: product.introductoryPrice?.subscriptionPeriod.unit, freeTrialDurationUnits: product.introductoryPrice?.subscriptionPeriod.numberOfUnits)
                self.view?.setReadyToBuy(localizedPrice: product.localizedPrice ?? "unknown", offer: offer, subscribeAction: self.startPurchaseWasTapped, reactivateAction: self.restorePurchaseWasTapped)

            case .unlinkedInAppPurchaseSubscription:
                self.view?.setUnlinkedInAppPurchaseSubscription(connectAction: self.linkPurchaseWasTapped, cancelAction: self.cancelSubscriptionWasTapped)
            case .activeInAppPurchaseSubscription:
                self.view?.setActiveInAppPurchaseSubscription(buttonAction: self.cancelSubscriptionWasTapped)
            case .activeExternalSubscription:
                self.view?.setActiveExternalSubscription()
            }

            switch state {
            case .loading, .temporaryError, .permanentError: break
            case .readyToBuy, .unlinkedInAppPurchaseSubscription, .activeInAppPurchaseSubscription, .activeExternalSubscription:
                if self.didTrackStoreLoaded == false {
                    self.didTrackStoreLoaded = true
                    analyticsTracker.track(.iapStoreLoaded)
                }
            }
        }
    }

    func startPurchaseWasTapped() {
        analyticsTracker.track(.iapSubscribeButtonClicked(info: inAppPurchaseApplicationService.purchaseInfo()))
        inAppPurchaseApplicationService.buyAndLink { [setError] result in
            if case .failure(let error) = result {
                setError(error, L10n.Iap.Store.Errormessage.purchasing)
            }
        }
    }

    func restorePurchaseWasTapped() {
        analyticsTracker.track(.iapRestoreButtonClicked(info: inAppPurchaseApplicationService.purchaseInfo()))
        inAppPurchaseApplicationService.restoreAndLink { [setError] result in
            if case .failure(let error) = result {
                setError(error, L10n.Iap.Store.Errormessage.restoring)
            }
        }
    }

    func linkPurchaseWasTapped() {
        analyticsTracker.track(.iapLinkButtonClicked(info: inAppPurchaseApplicationService.purchaseInfo()))
        inAppPurchaseApplicationService.link { [setError] result in
            if case .failure(let error) = result {
                setError(error, L10n.Iap.Store.Errormessage.linking)
            }
        }
    }

    func cancelSubscriptionWasTapped() {
        analyticsTracker.track(.iapCancelSubscriptionClicked(info: inAppPurchaseApplicationService.purchaseInfo()))
        coordinator.manageInAppPurchaseSubscription()
    }

    func contactSupportWasTapped() {
        coordinator.goToSupport()
    }

    func retryWasTapped() {
        inAppPurchaseApplicationService.updateStoreState()
    }

    func pageDidChange(_ page: Int) {
        analyticsTracker.track(.iapStorePerksPageChanged(info: inAppPurchaseApplicationService.purchaseInfo(), pageNumber: page))
    }

    deinit {
        analyticsTracker.track(.iapStoreClosed)
    }

    private func setError(_ error: InAppPurchaseApplicationServiceError, message: String) {
        var additionalMessage: String = L10n.Error.Generic.message

        if case .storeError(let error) = error {
            switch error.code {
            case .paymentCancelled: return // not actually an error
            case .paymentNotAllowed: additionalMessage = L10n.Iap.Store.Error.paymentNotAllowed
            case .cloudServiceNetworkConnectionFailed: additionalMessage = L10n.Error.Offline.message
            case .privacyAcknowledgementRequired: additionalMessage = L10n.Iap.Store.Error.privacyAcknowledgementRequired
            default: break
            }
        }

        let description = "\(message)\n\n\(additionalMessage)"
        let presentableMessage = PresentableMessage(title: L10n.Error.Generic.title, description: description, logLevel: .error)

        view?.presentError(presentableMessage, [.dismiss])
    }

    private func offer(for freeTrialDurationUnit: SKProduct.PeriodUnit?, freeTrialDurationUnits: Int?) -> String? {
        guard let freeTrialDurationUnit = freeTrialDurationUnit, let freeTrialDurationUnits = freeTrialDurationUnits else { return nil }

        let localizedDuration: String = {
            switch freeTrialDurationUnit {
            case .day: return freeTrialDurationUnits == 1 ? L10n.Iap.Store.Introductory.day : L10n.Iap.Store.Introductory.days
            case .week: return freeTrialDurationUnits == 1 ? L10n.Iap.Store.Introductory.week : L10n.Iap.Store.Introductory.weeks
            case .month: return freeTrialDurationUnits == 1 ? L10n.Iap.Store.Introductory.month : L10n.Iap.Store.Introductory.months
            case .year: return freeTrialDurationUnits == 1 ? L10n.Iap.Store.Introductory.year : L10n.Iap.Store.Introductory.year
            @unknown default: return ""
            }
        }()

        return "\(freeTrialDurationUnits) \(localizedDuration)"
    }
}
