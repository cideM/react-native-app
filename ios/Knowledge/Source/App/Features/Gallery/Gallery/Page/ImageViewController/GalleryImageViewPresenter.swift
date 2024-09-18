//
//  GalleryImageViewPresenter.swift
//  KnowledgeTests
//
//  Created by CSH on 04.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

final class GalleryImageViewPresenter: GalleryImageViewPresenterType {

    weak var delegate: GalleryImageViewPresenterDelegate?
    private var isDragging = false {
        didSet {
            if oldValue != isDragging {
                delegate?.didUpdateDraggingState(isDragging: isDragging)
            }
        }
    }

    weak var view: GalleryImageViewType?

    let image: ImageResourceType
    private let repository: GalleryImageRepositoryType
    private let coordinator: GalleryCoordinatorType
    private let tracker: GalleryAnalyticsTrackingProviderType

    init(image: ImageResourceType,
         repository: GalleryImageRepositoryType,
         coordinator: GalleryCoordinatorType,
         tracker: GalleryAnalyticsTrackingProviderType) {
        self.image = image
        self.repository = repository
        self.coordinator = coordinator
        self.tracker = tracker
    }

    private var overlayIsShown = false
    func toggleImageOverlay() {
        overlayIsShown.toggle()
        if overlayIsShown {
            tracker.trackShowImageOverlay(imageID: image.imageResourceIdentifier)
        } else {
            tracker.trackHideImageOverlay(imageID: image.imageResourceIdentifier)
        }
        loadCurrentImage()
    }

    func trackImageDescriptionPresented() {
        tracker.trackShowImageExplanations(imageID: image.imageResourceIdentifier)
    }

    func trackImageDescriptionDismissed() {
        tracker.trackHideImageExplanations(imageID: image.imageResourceIdentifier)
    }

    func openURL(_ url: URL) {
        coordinator.openURLExternally(url)
    }

    private func loadCurrentImage() {
        guard let image = overlayIsShown ? image.overlayImages.first : image.standardImages.first else { return }
        loadImage(for: image)
    }

    func navigate(to externalAddition: ExternalAddition) {
        coordinator.navigate(to: externalAddition.identifier) { [weak self] in
            guard let self = self else { return }
            if case .smartzoom = externalAddition.type {
                self.tracker.trackCloseSmartZoom(imageID: self.image.imageResourceIdentifier)
            }
        }
        if case .smartzoom = externalAddition.type {
            tracker.trackShowSmartZoom(imageID: image.imageResourceIdentifier)
        }
    }

    private func loadImage(for reference: ImageReference) {
        view?.setIsLoading(true)
        repository.loadImage(for: reference) { [weak self] result in
            self?.view?.setIsLoading(false)
            switch result {
            case .success(let image): self?.view?.setImage(image)
            case .failure(let error):
                let retry = MessageAction(title: L10n.Generic.retry, style: .normal) { [weak self] in
                    self?.loadCurrentImage()
                    return true
                }
                self?.view?.showError(error as PresentableMessageType, actions: [retry])
            }
        }
    }

    func viewWillAppear() {
        // Doing this here instead of in view.didSet() to make sure we always show the base image
        // when the view gets on screen, this is important in case the user triggered the overlay
        // and then swipes away and comes back. This way the pill toolbar and view will have
        // reset to initial values. Keeping state is likely not worth the effort.
        overlayIsShown = false
        let hasOverlay = !image.overlayImages.isEmpty
        view?.setExternalAdditions(image.externalAdditions, hasOverlay: hasOverlay)
        loadCurrentImage()
        tracker.trackShowImageMediaviewer(imageID: image.imageResourceIdentifier, title: image.title)
    }

    func viewDidDisappear() {
        tracker.trackCloseImageMediaviewer(imageID: image.imageResourceIdentifier, title: image.title)
    }

    func updateDraggingState(isDragging: Bool) {
        self.isDragging = isDragging
    }

    func setFullscreen(_ value: Bool) {
        self.delegate?.didUpdateFullscreen(value)
    }
}
