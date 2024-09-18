//
//  TableDetailPresenter.swift
//  Knowledge
//
//  Created by CSH on 03.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

protocol TableDetailPresenterType: WebViewBridgeDelegate {
    var view: TableDetailViewType? { get set }
}

final class TableDetailPresenter: TableDetailPresenterType {
    weak var view: TableDetailViewType? {
        didSet {
            view?.load(document: document)
        }
    }

    private let document: HtmlDocument
    private let coordinator: LearningCardCoordinatorType
    private let optionsRepository: LearningCardOptionsRepositoryType
    private let galleryRepository: GalleryRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let userDataClient: UserDataClient
    private let appConfiguration: Configuration
    private let tracker: LearningCardTracker
    private let htmlSizeCalculationService: HTMLContentSizeCalculatorType

    private var healthCareProfessionObserver: NSObjectProtocol?

    init(coordinator: LearningCardCoordinatorType,
         document: HtmlDocument,
         optionsRepository: LearningCardOptionsRepositoryType = resolve(),
         galleryRepository: GalleryRepositoryType,
         userDataRepository: UserDataRepositoryType = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         userDataClient: UserDataClient = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         tracker: LearningCardTracker,
         htmlSizeCalculationService: HTMLContentSizeCalculatorType = resolve()) {
        self.coordinator = coordinator
        self.document = document
        self.optionsRepository = optionsRepository
        self.galleryRepository = galleryRepository
        self.userDataRepository = userDataRepository
        self.remoteConfigRepository = remoteConfigRepository
        self.userDataClient = userDataClient
        self.appConfiguration = appConfiguration
        self.tracker = tracker
        self.htmlSizeCalculationService = htmlSizeCalculationService

        healthCareProfessionObserver = NotificationCenter.default.observe(for: ProfessionConfirmationDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] change in
            change.newValue ? self?.view?.revealTrademarks() : self?.view?.hideTrademarks()
        }
    }

    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback) {
        switch callback {
        case .`init`:
            view?.changeHighlightingMode(optionsRepository.isHighlightingModeOn)

            // Reveal or blur trademarks based on the current user health care profession.
            userDataRepository.hasConfirmedHealthCareProfession ?? false ? view?.revealTrademarks() : view?.hideTrademarks()

            if remoteConfigRepository.pharmaDosageTooltipV1Enabled {
                // Reveal new dosage entitities if enabled
                view?.revealDosages()
            }
        case .showTable, .commitFeedback, .editExtension, .sendMessageToUser, .manageSharedExtensions:
            break
        case .closePopover:
            coordinator.closePopover()
        case .openLearningCard(let learningCard):
            coordinator.navigate(to: learningCard, snippetAllowed: true)
            tracker.trackArticleSelected()
        case .showPopover(let htmlDocument, let tooltipType):
            htmlSizeCalculationService.calculateSize(for: htmlDocument) { [weak self] htmlContentSize in
                guard let self = self else { return }
                self.coordinator.showPopover(htmlDocument: htmlDocument, tracker: self.tracker, preferredContentSize: htmlContentSize)
            }
            tracker.trackTooltipOpen(tooltipType: tooltipType)
        case .showVideo(let video):
            coordinator.navigate(to: video.url, tracker: tracker)
        case .showImageGallery(let galleryDeeplink):
            if let externalAddition = galleryRepository.primaryExternalAddition(for: galleryDeeplink) {
                coordinator.navigate(to: externalAddition.identifier, tracker: tracker)
            } else {
                coordinator.showImageGallery(galleryDeeplink, tracker: tracker)
            }
        case .onSectionOpened, .onSectionClosed:
            break
        case .blurredTrademarkTapped:
            view?.showDisclaimerDialog { [weak self] isConfirmed in
                guard let self = self else { return }
                isConfirmed ? self.view?.revealTrademarks() : self.view?.hideTrademarks()
                self.userDataRepository.hasConfirmedHealthCareProfession = isConfirmed
                self.userDataClient.setHealthcareProfession(isConfirmed: isConfirmed) { _ in
                    // Ignore any error: If the request fails The dialog will just come up again next time.
                    // This is sent here immediately and not synced via UserDataSynchronizer
                    // cause there is no timestamp for this property, so the synchronizer
                    // would always use the value from the web, which would then discard
                    // the choice the user made here. Just pushing it directly solves the issue.
                }
            }
        case .dosageTapped(let dosageID):
            coordinator.showPopover(for: dosageID, tracker: tracker)
        }
    }
}
