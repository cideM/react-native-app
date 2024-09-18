//
//  GalleryRepository.swift
//  Knowledge
//
//  Created by CSH on 03.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import UIKit // We only use UIImage for this

/// @mockable
protocol GalleryRepositoryType: GalleryImageRepositoryType {
    func gallery(with identifier: GalleryIdentifier) throws -> Gallery
    func imageResource(for identifier: ImageResourceIdentifier) throws -> ImageResourceType
    func externalAdditionsForImage(at galleryDeeplink: GalleryDeeplink) throws -> [ExternalAddition]

    /// This function can be used to figure out if an image is only a placeholder image or if it stands for itself.
    ///
    /// Some images in the library are only technical placeholders that don't provide any value for themselves
    /// but just technically need to be there so they can reference an external feature. One example would be
    /// Meditricks placeholder images.
    ///
    /// All images that are just placeholder images should not appear when showing a gallery but should
    /// be filtered out. When tapping an image that is just a placeholder image in the article, the gallery
    /// should not be shown, but the external content should be opened directly.
    ///
    /// - Parameter galleryDeeplink: The gallery deeplink pointing to a specific image within a gallery
    /// - Returns: A boolean describing if this referenced image is a placeholder image or not.
    func hasPlaceholderImage(for galleryDeeplink: GalleryDeeplink) throws -> Bool

    // In case this function returns a key, the appropriae feature shall be opened directly
    // without making the detour across the gallery screen
    func primaryExternalAddition(for galleryDeeplink: GalleryDeeplink) -> ExternalAddition?
}

/// @mockable
protocol GalleryImageRepositoryType {
    func loadImage(for reference: ImageReference, completion: @escaping (Result<UIImage, NetworkError<EmptyAPIError>>) -> Void)
}

final class GalleryRepository {
    private let libraryRepository: LibraryRepositoryType
    private let mediaClient: MediaClient

    @Inject var monitor: Monitoring

    init(libraryRepository: LibraryRepositoryType = resolve(), mediaClient: MediaClient = resolve()) {
        self.libraryRepository = libraryRepository
        self.mediaClient = mediaClient
    }
}

extension GalleryRepository: GalleryRepositoryType {

    func gallery(with identifier: GalleryIdentifier) throws -> Gallery {
        try libraryRepository.library.gallery(with: identifier)
    }

    func imageResource(for identifier: ImageResourceIdentifier) throws -> ImageResourceType {
        try libraryRepository.library.imageResource(for: identifier)
    }

    func loadImage(for reference: ImageReference, completion: @escaping (Result<UIImage, NetworkError<EmptyAPIError>>) -> Void) {
        mediaClient.downloadData(at: reference.source) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NetworkError<EmptyAPIError>.other("Could not instantiate an image from the downloaded data.")))
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func externalAdditionsForImage(at galleryDeeplink: GalleryDeeplink) throws -> [ExternalAddition] {
        let gallery = try self.gallery(with: galleryDeeplink.gallery)
        let imageResource = try self.imageResource(for: gallery.images[galleryDeeplink.imageOffset])
        return imageResource.externalAdditions
    }

    func hasPlaceholderImage(for galleryDeeplink: GalleryDeeplink) throws -> Bool {
        let gallery = try self.gallery(with: galleryDeeplink.gallery)
        let selectedImageResource = try imageResource(for: gallery.images[galleryDeeplink.imageOffset])
        return hasPlaceholderImage(for: selectedImageResource)
    }

    func primaryExternalAddition(for galleryDeeplink: GalleryDeeplink) -> ExternalAddition? {
        do {
            let selectedImageExternalAdditions = try externalAdditionsForImage(at: galleryDeeplink)
            if let externalAddition = selectedImageExternalAdditions.first, try hasPlaceholderImage(for: galleryDeeplink) {
                return externalAddition
            }
        } catch {
            monitor.warning("Couldn't open popover for deeplink: \(galleryDeeplink.gallery.description)", context: .navigation)
        }

        return nil
    }

    private func hasPlaceholderImage(for imageResource: ImageResourceType) -> Bool {
        guard imageResource.externalAdditions.count == 1, let externalAddition = imageResource.externalAdditions.first else { return false }
        return externalAddition.type.hasPlaceholderImage
    }
}
