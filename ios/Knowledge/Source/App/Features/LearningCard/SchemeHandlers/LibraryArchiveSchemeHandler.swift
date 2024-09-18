//
//  LearningCardURLSchemeHandler.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 28.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import WebKit

// WKWebView retains a once assigned scheme handler and never lets go, workaround is this proxy object
// See here for more details:
// https://stackoverflow.com/questions/71678534/swift-seturlschemehandler-causes-a-memory-leak-wkwebview
// This is rather a problem for `LibraryArchiveSchemeHandler` than for `CommonBundleSchemeHandler` cause
// `LibraryArchiveSchemeHandler` makes network requests which might come back after the affiliated webview did navigate
// to another page already or has been deallocated. Both scenarios lead to a crash. Hence it's very important
// that the handler gets deallocated and stops all ongoing tasks (that might fire at a later point) while doing so.
class WeakURLSchemeHandlerWrapper: NSObject, WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        self.handler?.webView(webView, start: urlSchemeTask)
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        self.handler?.webView(webView, stop: urlSchemeTask)
    }

    weak var handler: WKURLSchemeHandler?
    init (_ handler: WKURLSchemeHandler) {
        self.handler = handler
        super.init()
    }
}

/// The LibraryArchiveSchemeHandler is responsible to to load data from the library archive. It can be used to fetch
/// any file directly, or load a learningcard and wrap it in some html so it can be properly displayed.
/// In case of a partial archive it will also try to fetch the learningcard from the server.
///
/// Supported URL formats
/// * libraryarchive://_/_learningcard/<learningcard-xid> will find the according learningcard, wrap it in the according html wrapper and load it
/// * libraryarchive://_/<filepath> will try to find the file referenced and return it
/// * any other will fail
final class LibraryArchiveSchemeHandler: NSObject {

    static let scheme = "libraryarchive"
    static let host = "_" // In this implementation the host actually doesn't matter
    static let learningcardFolderPrefix = "_learningcard"

    private let monitor: Monitoring = resolve()

    private let libraryRepository: LibraryRepositoryType
    private let client: LearningCardLibraryClient

    private var asyncTasks = [(WKURLSchemeTask, Task<(), Never>)]()

    init(libraryRepository: LibraryRepositoryType = resolve(), client: LearningCardLibraryClient = resolve()) {
        self.libraryRepository = libraryRepository
        self.client = client
    }

    deinit {
        asyncTasks.stopAll()
    }

    static func baseUrl() -> URL {
        URL(string: "\(Self.scheme)://\(Self.host)")! // swiftlint:disable:this force_unwrapping
    }

    static func url(for learningCard: LearningCardIdentifier) -> URL {
        let baseUrl = baseUrl()
        return baseUrl.appendingPathComponent(Self.learningcardFolderPrefix).appendingPathComponent(learningCard.value)
    }
}

extension LibraryArchiveSchemeHandler: WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {

        // WKURLSchemeTask's hashes are different for tasks with the same URL fired at different times
        // That should give enough "uniqueness" to avoid any conflicts between overlapping requests to the same URL
        let asyncTask = Task.detached { [weak self] in
            do {
                guard let url = task.request.url, task.request.url?.scheme == Self.scheme else {
                    throw Error.malformedURL(String(describing: task.request.url))
                }

                // This would only return early if the handler got deallocated while waiting for the result
                // In which case there is no need any more to call "task.didReceive" or "task.didFailWithError"
                guard let (response, data) = try await self?.load(url) else {
                    return
                }

                // Returning data from a stopped task crashes the app,
                // hence we check this beforehand ...
                if self?.asyncTasks.isRunning(task) ?? false {
                    task.didReceive(response)
                    task.didReceive(data)
                    task.didFinish()
                }
            } catch {
                self?.monitor.error(error, context: .library)
                // The error returned here will only bubble up to WKNavigationDelegate.didFailProvisionalNavigation
                // if it is the first time webView(start:) is invoked, means its usually this URL:
                // libraryarchive://host/_learningcard/<learningcard-xid>
                // If any later operations (usually for supplementary files) fail the webview
                // will not receive an error and just remain forever in a "loading" state
                // ---
                // Notable other errors arriving here will be of type `CancellationError` originating from cancelled async Tasks
                // These will fail the `tasks.isRunning(request)` check and hence will not invoke task.didFailWithError ...
                if self?.asyncTasks.isRunning(task) ?? false {
                    task.didFailWithError(error)
                }
            }
        }

        asyncTasks.append((task, asyncTask))
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Its likely that this is called when, the user:
        // * has a very slow network connection
        // * has only the "partial archive" as library
        // * has not updated yet to the full library
        // To reproduce the issue:
        // * Make sure your device is on a slow network connection (for example via proxy)
        // * Make sure no library update can be downloaded (for example via proxy)
        // * Open any leanrning card and wait till its loaded
        // * Now follow any link to another card and tap the back button before it loaded
        // -> This method will be called in LearngingCardViewController.webView(_ webView, didFailProvisionalNavigation, withError)
        // -> The error will have code -999 (cancelled) and explicitly be skipped in the LearngingCardViewController logic
        asyncTasks.stop(urlSchemeTask)
    }
}

// Article loading
private extension LibraryArchiveSchemeHandler {

    func load(_ url: URL) async throws -> (URLResponse, Data) {
        switch url.path.starts(with: "/\(Self.learningcardFolderPrefix)") {
        case true:
            let id = LearningCardIdentifier(value: url.lastPathComponent)
            let data = try await loadArticle(id: id)
            try Task.checkCancellation()
            let response = URLResponse(url: url, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil)
            return (response, data)
        default:
            do {
                let data = try libraryRepository.library.data(at: url.path)
                let response = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
                return (response, data)
            } catch {
                throw Error.fileMissing(path: url.path, underlyingError: error)
            }
        }
    }

    func loadArticle(id: LearningCardIdentifier) async throws -> Data {
        do {
            return try loadLearningcardFromArchive(id: id)
        } catch {
            return try await loadLearningcardOnline(id: id)
        }
    }

    func loadLearningcardFromArchive(id: LearningCardIdentifier) throws -> Data {
        let body = try libraryRepository.library.learningCardHtmlBody(for: id)
        let html = HtmlDocument.libraryDocument(body: body)
        guard let htmlData = html.asData else {
            throw Error.dataConversionFailed(id)
        }
        return htmlData
    }

    func loadLearningcardOnline(id: LearningCardIdentifier) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            loadLearningcardOnline(id: id) {
                continuation.resume(with: $0)
            }
        }
    }

    func loadLearningcardOnline(id: LearningCardIdentifier, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        client.getLearningCardHtml(libraryVersion: libraryRepository.library.metadata.versionId, learningCard: id) { result in
            switch result {
            case .success(let body):
                let html = HtmlDocument.libraryDocument(body: body)
                if let data = html.asData {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.dataConversionFailed(id)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// That's all just syntactic sugar to make the logic above read nicer ...

extension LibraryArchiveSchemeHandler {
    enum Error: Swift.Error {
        case malformedURL(String)
        case fileMissing(path: String, underlyingError: Swift.Error)
        case dataConversionFailed(LearningCardIdentifier)
    }
}

fileprivate extension Array where Element == (WKURLSchemeTask, Task<(), Never>) {

    func isRunning(_ urlSchemeTask: WKURLSchemeTask) -> Bool {
        if let asyncTask = self.first(where: { $0.0 === urlSchemeTask })?.1, !asyncTask.isCancelled {
            return true
        } else {
            return false
        }
    }

    func stop(_ urlSchemeTask: WKURLSchemeTask) {
        self.first(where: { $0.0 === urlSchemeTask })?.1.cancel()
    }

    func stopAll() {
        for (_, asyncTask) in self where !asyncTask.isCancelled {
            asyncTask.cancel()
        }
    }
}
