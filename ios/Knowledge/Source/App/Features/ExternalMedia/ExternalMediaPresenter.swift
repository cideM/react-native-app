//
//  ExternalMediaPresenter.swift
//  Knowledge
//
//  Created by CSH on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization

/// @mockable
protocol ExternalMediaPresenterType: WebViewPresenterType {
    func fetchAndShowExternalAddition(with identifier: ExternalAdditionIdentifier)
    func showExternalAddition(with url: URL, and type: ExternalAddition.Types)
    func dismissExternalAddition()
}

final class ExternalMediaPresenter: ExternalMediaPresenterType {

    weak var view: WebViewControllerType? {
        didSet {
            update(view: view, with: state)
        }
    }

    private var state = LoadingState.loading {
        didSet {
            update(view: view, with: state)
        }
    }
    private var externalAdditionId: ExternalAdditionIdentifier?
    private var url: URL?
    private var type: ExternalAddition.Types?
    private let externalMediaRepository: ExternalMediaRepositoryType
    private let accessRepository: AccessRepositoryType
    private let coordinator: ExternalMediaCoordinatorType
    private let galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderType
    private let appConfiguration: Configuration

    init(externalMediaRepository: ExternalMediaRepositoryType = resolve(),
         accessRepository: AccessRepositoryType = resolve(),
         coordinator: ExternalMediaCoordinatorType,
         galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderType,
         appConfiguration: Configuration = AppConfiguration.shared) {

        self.externalMediaRepository = externalMediaRepository
        self.accessRepository = accessRepository
        self.coordinator = coordinator
        self.galleryAnalyticsTrackingProvider = galleryAnalyticsTrackingProvider
        self.appConfiguration = appConfiguration
    }

    func failedToLoad(with error: Error) {
        let retryAction = MessageAction(title: L10n.Generic.retry, style: .primary) { [weak self] in
            self?.retryFlow()
            return true
        }
        if let error = error as? PresentableMessageType {
            view?.showError(error, actions: [retryAction])
        } else {
            view?.showError(UnknownError.unknown, actions: [retryAction])
        }
    }

    func dismissExternalAddition() {
        guard let type = type, type != .video else { return }
        galleryAnalyticsTrackingProvider.trackCloseImageMediaviewer(externalAdditionType: type.rawValue)
    }

    func fetchAndShowExternalAddition(with identifier: ExternalAdditionIdentifier) {
        self.externalAdditionId = identifier

        self.fetchExternalAdditionAndCheckPermissions(with: identifier) { [weak self] url, type in
            self?.showExternalAddition(with: url, and: type)
        }
    }

    func showExternalAddition(with url: URL, and type: ExternalAddition.Types) {
        self.url = url
        self.type = type

        self.trackOpeningExternalAddition(with: url, and: type)
        self.state = .loaded(url)
    }

    private func fetchExternalAdditionAndCheckPermissions(with identifier: ExternalAdditionIdentifier, completion: @escaping (URL, ExternalAddition.Types) -> Void) {
        externalMediaRepository.getExternalAddition(for: identifier) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let externalAddition):
                self.accessRepository.getAccess(for: externalAddition) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        guard let url = externalAddition.url else { return }
                        self.showExternalAddition(with: url, and: externalAddition.type)
                    case .failure(let error):
                        self.presentPaywall(for: error)
                    }
                }
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func trackOpeningExternalAddition(with url: URL, and type: ExternalAddition.Types) {
        if type == .video {
            galleryAnalyticsTrackingProvider.trackShowVideoMediaviewer(url: url)

        } else {
            galleryAnalyticsTrackingProvider.trackShowImageMediaviewer(imageID: nil, title: nil, externalAdditionType: type.rawValue)
        }
    }

    private func update(view: WebViewControllerType?, with state: LoadingState) {
        guard let view = view else { return }
        switch state {
        case .loading:
            view.setIsLoading(true)
        case .failed(let error):
            view.setIsLoading(false)
            if let error = error as? PresentableMessageType {
                view.showError(error, actions: [tryAgainAction()])
            } else {
                view.showError(UnknownError.unknown, actions: [tryAgainAction(), buyLicenseAction()])
            }
        case .loaded(let url):
            view.setIsLoading(false)
            self.view?.loadRequest(self.request(for: url))
        }
    }

    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        let urlString = url.absoluteString

        if urlString.contains("meditricks.de") {
            // Meditricks requires us to set a specific referer
            request.addValue(appConfiguration.meditricksRefererUrl.absoluteString, forHTTPHeaderField: "Referer")

        } else if urlString.contains("easyradiology.net") {
            // This is needed to enable css tailored for amboss. Easyradiology implemented this on our request
            // Without this header the website will use Easyradiologys default css which looks less nice
            request.setValue("Amboss", forHTTPHeaderField: "Referer")

        } else if urlString.contains("smartzoom.com") {
            // This currently does nothing on the server side, we're planning to enforce this at some point in future
            // when enough clients have adopted the behavior of sending the referer ...
            for field in ["Origin", "Referer"] {
                request.setValue(appConfiguration.smartzoomRefererUrl.absoluteString, forHTTPHeaderField: field)
            }
        }

        return request
    }
}

private extension ExternalMediaPresenter {
    enum LoadingState {
        case loading
        case failed(Error)
        case loaded(URL)
    }
}

private extension ExternalMediaPresenter {
    func presentPaywall(for accessError: AccessError) {
        let messageTitle: String
        let messageDescription: String
        let messageActions: [MessageAction]

        switch accessError {
        case .accessRequired:
            messageTitle = L10n.InAppPurchase.Paywall.AccessRequired.title
            messageDescription = L10n.InAppPurchase.Paywall.AccessRequired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .offlineAccessExpired:
            messageTitle = L10n.InAppPurchase.Paywall.OfflineAccessExpired.title
            messageDescription = L10n.InAppPurchase.Paywall.OfflineAccessExpired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .campusLicenseUserAccessExpired:
            messageTitle = L10n.InAppPurchase.Paywall.CampusLicenseExpired.title
            messageDescription = L10n.InAppPurchase.Paywall.CampusLicenseExpired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .unknown:
            messageTitle = L10n.InAppPurchase.Paywall.UnknownAccessError.title
            messageDescription = L10n.InAppPurchase.Paywall.UnknownAccessError.message
            messageActions = [tryAgainAction(style: .primary), buyLicenseAction(style: .normal)]
        default: return
        }

        view?.showError(PresentableMessage(title: messageTitle, description: messageDescription, logLevel: .info), actions: messageActions)
    }

    func tryAgainAction(style: MessageAction.Style = .normal) -> MessageAction {
        MessageAction(title: L10n.Generic.retry, style: style) {
            self.retryFlow()
            return true
        }
    }
    func buyLicenseAction(style: MessageAction.Style = .primary) -> MessageAction {
        MessageAction(title: L10n.InAppPurchase.Paywall.buyLicense, style: style) { [ coordinator, galleryAnalyticsTrackingProvider] in
            coordinator.goToStore()
            galleryAnalyticsTrackingProvider.trackNoAccessBuyLicense()
            return true
        }
    }

    func retryFlow() {
        if let url = self.url, let type = self.type {
            self.showExternalAddition(with: url, and: type)
        } else if let identifier = self.externalAdditionId {
            self.fetchAndShowExternalAddition(with: identifier)
        }
    }
}
