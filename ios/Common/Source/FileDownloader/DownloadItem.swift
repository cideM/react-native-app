//
//  DownloadItem.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 31.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension FileDownloader {
    struct DownloadItem {
        let task: URLSessionDownloadTask
        let destinationURL: URL
        let progress: (Double) -> Void
        let completion: (Result<(), FileDownloaderError>) -> Void
    }
}
