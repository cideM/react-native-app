//
//  FileDownloader.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 30.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// @mockable
public protocol FileDownloaderType {
    func download(from sourceURL: URL, to destinationURL: URL, progress: @escaping (Double) -> Void, completion: @escaping (Result<(), FileDownloaderError>) -> Void)
    func cancel()
}

public enum FileDownloaderError: Error {
    case fileWithTheSameNameExistsInTheDestination
    case network(underlying: Error)
    case fileSystem(underlying: Error)
}

public final class FileDownloader: NSObject {
    private let workingDirectory: URL
    private var runningDownload: DownloadItem?
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    public init(workingDirectory: URL = FileManager.default.temporaryDirectory.appendingPathComponent("FileDownloaderWorkingDirectory")) throws {
        self.workingDirectory = workingDirectory
        do {
            if !FileManager.default.fileExists(atPath: workingDirectory.path) {
                try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: false)
            } else {
                try FileManager.default.removeItems(at: workingDirectory, olderThan: 7.days)
            }
        } catch {
            throw FileDownloaderError.fileSystem(underlying: error)
        }
    }

    private func resumeDataURL(for destinationURL: URL) -> URL {
        workingDirectory.appendingPathComponent(destinationURL.lastPathComponent + "_resumeData")
    }
}

extension FileDownloader: FileDownloaderType {

    public func download(from sourceURL: URL, to destinationURL: URL, progress: @escaping (Double) -> Void, completion: @escaping (Result<(), FileDownloaderError>) -> Void) {
        guard !FileManager.default.fileExists(atPath: destinationURL.path) else { return completion(.failure(.fileWithTheSameNameExistsInTheDestination)) }

        let task: URLSessionDownloadTask
        let resumeDataUrl = resumeDataURL(for: destinationURL)

        if let resumeData = try? Data(contentsOf: resumeDataUrl, options: .alwaysMapped) {
            task = session.downloadTask(withResumeData: resumeData)
        } else {
            task = session.downloadTask(with: sourceURL)
        }

        task.resume()
        runningDownload = DownloadItem(task: task, destinationURL: destinationURL, progress: progress, completion: completion)
    }

    public func cancel() {
        runningDownload?.task.cancel()
    }
}

extension FileDownloader: URLSessionTaskDelegate, URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard downloadTask.originalRequest?.url != nil, let runningDownload = runningDownload else { return }

        do {
            try FileManager.default.moveItem(at: location, to: runningDownload.destinationURL)
            try? FileManager.default.removeItem(at: resumeDataURL(for: runningDownload.destinationURL)) // Remove resumeData if there was any.
        } catch {
            runningDownload.completion(.failure(.network(underlying: error)))
        }

        runningDownload.completion(.success(()))
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard (downloadTask.originalRequest?.url) != nil, totalBytesWritten > 0 else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        runningDownload?.progress(progress)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }

        let userInfo = (error as NSError).userInfo
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data, let destinationURL = runningDownload?.destinationURL {
            let resumeDataUrl = resumeDataURL(for: destinationURL)
            try? resumeData.write(to: resumeDataUrl)
        }

        runningDownload?.completion(.failure(.network(underlying: error)))
    }
}
