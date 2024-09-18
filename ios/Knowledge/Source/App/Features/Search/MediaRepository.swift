//
//  MediaRepository.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 04.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Networking

public enum MediaRepositoryError: Error {
    case failedToDownload(_ developerDescription: String)
}

/// @mockable
protocol MediaRepositoryType {
    func image(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func clearCache()
}

final class MediaRepository: MediaRepositoryType {
    private let mediaClient: MediaClient
    private let cache = NSCache<NSURL, UIImage>()

    init(mediaClient: MediaClient = resolve()) {
        self.mediaClient = mediaClient
    }

    func image(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {

        if let image = cache.object(forKey: url as NSURL) {
            // use the cached version
            completion(.success(image))
        } else {
            mediaClient.downloadData(at: url) { result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self.cache.setObject(image, forKey: url as NSURL)
                        completion(.success(image))
                    } else {
                        completion(.failure(MediaRepositoryError.failedToDownload("Couldn't create the image")))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
