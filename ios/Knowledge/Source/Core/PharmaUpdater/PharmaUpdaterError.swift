//
//  PharmaUpdaterError.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common

enum PharmaUpdaterError: Error {
    case downloaderError(FileDownloaderError)
    case underlyingError(error: Error? = nil)
    case unzippingFailed(UnzipperError)
    case invalidFilenameInDatabaseDownloadURL(urlString: String)
    case unexpectedPharmaDatabaseFilenameInArchive
    case canceled
}
