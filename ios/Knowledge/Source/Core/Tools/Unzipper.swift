//
//  Unzipper.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 27.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import ZIPFoundation
import Foundation

enum UnzipperError: Error {
    case storageExceeded
    case other(Error)

    init(ssZipArchiveError: Error?) {
        guard let ssZipArchiveError = ssZipArchiveError else {
            self = .other(UnknownError.unknown)
            return
        }

        switch (ssZipArchiveError as NSError).code {
        case -5:
            self = .storageExceeded
        default:
            self = .other(ssZipArchiveError)
        }
    }
}

/// @mockable
protocol UnzipperType {
    func unzipFileAtPath(_ path: String, toDestination: String, completion: @escaping (Result<Void, UnzipperError>) -> Void)
}

final class Unzipper: UnzipperType {
    func unzipFileAtPath(_ path: String, toDestination: String, completion: @escaping (Result<Void, UnzipperError>) -> Void) {
        assert(!Thread.isMainThread)
        do {
            try FileManager.default.unzipItem(at: .init(fileURLWithPath: path), to: .init(fileURLWithPath: toDestination))
            completion(.success(()))
        } catch {
            completion(.failure(UnzipperError(ssZipArchiveError: error)))
        }
    }
}
