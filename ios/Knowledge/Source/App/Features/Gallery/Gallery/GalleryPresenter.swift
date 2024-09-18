//
//  GalleryPresenter.swift
//  Knowledge
//
//  Created by CSH on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol GalleryPresenterType: AnyObject {
    var view: GalleryViewType? { get set }
    var learningCardTitle: String? { get }
}

final class GalleryPresenter: GalleryPresenterType {
    weak var view: GalleryViewType? {
        didSet {
            if let view = view, let deeplink = initialDeeplink {
                go(to: deeplink, in: view)
            } else if let view = view, let imageResourceIdentifier = initialImageResourceIdentifier {
                go(to: imageResourceIdentifier, in: view)
            }
        }
    }

    let learningCardTitle: String?

    private let repository: GalleryRepositoryType
    private var initialDeeplink: GalleryDeeplink?
    private var initialImageResourceIdentifier: ImageResourceIdentifier?
    private let coordinator: GalleryCoordinatorType
    private let tracker: GalleryAnalyticsTrackingProviderType
    @Inject private var monitor: Monitoring

    init(repository: GalleryRepositoryType,
         coordinator: GalleryCoordinatorType,
         tracker: GalleryAnalyticsTrackingProviderType,
         learningCardTitle: String?) {
        self.repository = repository
        self.coordinator = coordinator
        self.tracker = tracker
        self.learningCardTitle = learningCardTitle
    }

    func go(to deeplink: GalleryDeeplink) {
        guard let view = view else {
            initialDeeplink = deeplink
            return
        }
        go(to: deeplink, in: view)
    }

    private func go(to deeplink: GalleryDeeplink, in view: GalleryViewType) {
        do {
            let gallery = try repository.gallery(with: deeplink.gallery)
            let images = try gallery.images.map { try repository.imageResource(for: $0) }

            let selectedImage = images[deeplink.imageOffset]
            let imagesWithoutPlaceholder = images.enumerated()
                .filter { (try? !repository.hasPlaceholderImage(for: GalleryDeeplink(gallery: deeplink.gallery, imageOffset: $0.offset))) ?? true }
                .map { $0.element }
            var deduplicatedImages: [ImageResourceType] = []
            for image in imagesWithoutPlaceholder where !deduplicatedImages.contains(where: { $0.imageResourceIdentifier == image.imageResourceIdentifier }) {
                deduplicatedImages.append(image)
            }

            let selectedImageOffsetAfterFiltering = deduplicatedImages.firstIndex { $0.imageResourceIdentifier == selectedImage.imageResourceIdentifier }

            let presenters = deduplicatedImages.map {
                GalleryImageViewPresenter(image: $0,
                                          repository: repository,
                                          coordinator: coordinator,
                                          tracker: tracker)
            }
            view.setImagePresenters(presenters)
            if let imageIndex = selectedImageOffsetAfterFiltering, imageIndex < deduplicatedImages.count {
                view.goToImage(atIndex: imageIndex, animated: false)
            }
        } catch {
            monitor.warning("Failed to navigate to gallery with deeplink \(deeplink) in view \(view) with error: \(error)", context: .navigation)
        }
    }

    func go(to imageResourceIdentifier: ImageResourceIdentifier) {
        guard let view = view else {
            initialImageResourceIdentifier = imageResourceIdentifier
            return
        }

        go(to: imageResourceIdentifier, in: view)
    }

    private func go(to imageResourceIdentifier: ImageResourceIdentifier, in view: GalleryViewType) {
        do {
            let imageResource = try repository.imageResource(for: imageResourceIdentifier)
            let presenter = GalleryImageViewPresenter(image: imageResource,
                                                      repository: repository,
                                                      coordinator: coordinator,
                                                      tracker: tracker)
            view.setImagePresenters([presenter])
            view.goToImage(atIndex: 0, animated: false)
        } catch {
            monitor.error(GalleryError.navigationFailedWithImageResourceIdentifier(error), context: .library)
        }
    }

    private enum GalleryError: Error {
        case navigationFailedWithImageResourceIdentifier(_ error: Error?)
    }
}
