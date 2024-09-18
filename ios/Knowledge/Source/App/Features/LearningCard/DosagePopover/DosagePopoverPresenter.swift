//
//  DosagePopoverPresenter.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 12.04.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

protocol DosagePopoverPresenterType: WebViewBridgeDelegate {
    var view: DosagePopoverViewType? { get set }
    func didTap(ambossSubstanceLink: AmbossSubstanceLink)
}

final class DosagePopoverPresenter: DosagePopoverPresenterType {

    weak var view: DosagePopoverViewType? {
        didSet {
            pharmaRepository.dosage(for: dosageIdentifier) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    self.tracker.trackArticleDosageOpenFailed(dosageID: self.dosageIdentifier, error: error)
                    self.handleError(error)

                case .success(let (dosage, source)):
                    var substanceName: String?
                    var substanceLink: AmbossSubstanceLink?

                    // Only show link to amboss substance if the feature flag is enabled
                    if self.remoteConfigRepository.pharmaDosageNGDENavigationEnabled {
                        substanceName = dosage.ambossSubstanceLink?.name
                        substanceLink = dosage.ambossSubstanceLink
                    }

                    let viewData = DosagePopoverViewData(html: dosage.html,
                                                         ambossSubstanceName: substanceName,
                                                         ambossSubstanceLink: substanceLink)
                    self.updateView(with: viewData, source: source)
                }
            }
        }
    }

    private let libraryCoordinator: LibraryCoordinatorType
    private let learningCardCoordinator: LearningCardCoordinatorType
    private let pharmaRepository: PharmaRepositoryType
    private let dosageIdentifier: DosageIdentifier
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let tracker: LearningCardTracker

    init(libraryCoordinator: LibraryCoordinatorType,
         learningCardCoordinator: LearningCardCoordinatorType,
         pharmaRepository: PharmaRepositoryType = resolve(),
         dosageIdentifier: DosageIdentifier,
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         tracker: LearningCardTracker) {
        self.libraryCoordinator = libraryCoordinator
        self.learningCardCoordinator = learningCardCoordinator
        self.pharmaRepository = pharmaRepository
        self.dosageIdentifier = dosageIdentifier
        self.remoteConfigRepository = remoteConfigRepository
        self.tracker = tracker
    }

    func didTap(ambossSubstanceLink: AmbossSubstanceLink) {
        guard let deeplink = ambossSubstanceLink.deeplink else { return }
        tracker.trackArticleDosageLinkClicked(dosageID: dosageIdentifier,
                                              ambossSubstanceLink: ambossSubstanceLink)
        switch deeplink {
        case .pharmaCard(let pharmaCardDeeplink):
            learningCardCoordinator.navigate(to: pharmaCardDeeplink)
        case .monograph(let monographDeeplink):
            learningCardCoordinator.navigate(to: monographDeeplink)
        }

    }

    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback) {
        switch callback {
        case .`init`, .showTable, .showPopover, .commitFeedback, .editExtension, .sendMessageToUser, .manageSharedExtensions, .onSectionOpened, .onSectionClosed, .blurredTrademarkTapped, .dosageTapped, .closePopover, .showVideo, .showImageGallery:
            break

        case .openLearningCard(let learningCard):
            libraryCoordinator.showLearningCard(learningCard)
            tracker.trackArticleSelected()
        }
    }
}

private extension DosagePopoverPresenter {

    func updateView(with viewData: DosagePopoverViewData, source: Metrics.Source) {
        self.view?.setContent(viewData)
        let source: DataSource = source == .online ? .online : .offline
        self.tracker.trackArticleDosageOpened(dosageID: self.dosageIdentifier, source: source)
    }

    func handleError(_ error: NetworkError<EmptyAPIError>) {
        switch error {
        case .noInternetConnection:
            learningCardCoordinator.showError(title: L10n.Error.Offline.title, message: L10n.Dosage.Error.Offline.message)
        default:
            learningCardCoordinator.showError(title: L10n.Error.Generic.title, message: L10n.Error.Generic.message)
        }
    }
}
