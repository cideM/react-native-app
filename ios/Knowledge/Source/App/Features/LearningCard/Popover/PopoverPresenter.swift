//
//  PopoverPresenter.swift
//  Knowledge
//
//  Created by CSH on 13.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

protocol PopoverPresenterType: WebViewBridgeDelegate {
    var view: PopoverViewType? { get set }

    func openURL(_ url: URL)
    func didFinishUrlLoading()
    func boundsChanged()
}

final class PopoverPresenter: PopoverPresenterType {

    weak var view: PopoverViewType? {
        didSet {
            view?.setIsLoading(true)
            view?.load(document: document)
        }
    }

    private let coordinator: LearningCardCoordinatorType
    private let document: HtmlDocument
    private let galleryRepository: GalleryRepositoryType
    private let tracker: LearningCardTracker
    private let htmlSizeCalculationService: HTMLContentSizeCalculatorType

    init(coordinator: LearningCardCoordinatorType,
         document: HtmlDocument,
         galleryRepository: GalleryRepositoryType,
         tracker: LearningCardTracker,
         htmlSizeCalculationService: HTMLContentSizeCalculatorType = resolve()) {
        self.coordinator = coordinator
        self.document = document
        self.galleryRepository = galleryRepository
        self.tracker = tracker
        self.htmlSizeCalculationService = htmlSizeCalculationService
    }

    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback) {
        switch callback {
        case .`init`, .showTable, .showPopover, .commitFeedback, .editExtension, .sendMessageToUser, .manageSharedExtensions, .onSectionOpened, .onSectionClosed, .blurredTrademarkTapped, .dosageTapped:
            break
        case .openLearningCard(let learningCard):
            coordinator.navigate(to: learningCard, snippetAllowed: true)
            tracker.trackArticleSelected()
        case .closePopover:
            coordinator.closePopover()
        case .showVideo(let video):
            coordinator.openURLExternally(video.url)
        case .showImageGallery(let galleryDeeplink):
            if let externalAddition = galleryRepository.primaryExternalAddition(for: galleryDeeplink) {
                coordinator.navigate(to: externalAddition.identifier, tracker: tracker)
            } else {
                coordinator.showImageGallery(galleryDeeplink, tracker: tracker)
            }
        }
    }

    func openURL(_ url: URL) {
        coordinator.openURLInternally(url)
    }

    func didFinishUrlLoading() {
        view?.setIsLoading(false)
    }

    func boundsChanged() {
        htmlSizeCalculationService.calculateSize(for: document, width: AppConfiguration.shared.popoverWidth) { [weak self] popoverContentSize in
            self?.view?.preferredContentSize = popoverContentSize
        }
    }
}
