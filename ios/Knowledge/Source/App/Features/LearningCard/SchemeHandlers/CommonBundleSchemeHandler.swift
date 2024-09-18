//
//  CommonBundleSchemeHandler.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 27.10.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import WebKit

final class CommonBundleSchemeHandler: NSObject, WKURLSchemeHandler {

    static let scheme: String = "commonbundle"
    static let host = "_" // In this implementation the host actually doesn't matter

    private static let bundle = Bundle(for: Common.EmptyClass.self)
    private let monitor: Monitoring = resolve()

    static func baseUrl() -> URL {
        URL(string: "\(Self.scheme)://\(Self.host)")! // swiftlint:disable:this force_unwrapping
    }

    static func url(for path: String) -> URL {
        assert(bundle.url(forResource: path, withExtension: nil) != nil)
        return baseUrl().appendingPathComponent(path)
    }

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else {
            let error = Error.missingURL
            task.finish(error: error)
            monitor.error(error, context: .library)
            return
        }

        guard let fileURL = Self.bundle.url(forResource: url.path, withExtension: nil) else {
            task.finish(error: .missingFile(url.path))
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
            task.finish(response: response, data: data)
        } catch {
            let error = Error.missingFile(String(describing: url))
            monitor.error(error, context: .library)
            task.finish(error: error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        assertionFailure("This should never be called ...")
    }
}

// Thats all just syntactic sugar to make the logic above read nicer ...
extension CommonBundleSchemeHandler {

    enum Error: Swift.Error {
        case missingURL
        case missingFile(String)
    }
}

fileprivate extension WKURLSchemeTask {

    func finish(response: URLResponse, data: Data) {
        finish(with: .success((response, data)))
    }

    func finish(error: CommonBundleSchemeHandler.Error) {
        finish(with: .failure(error))
    }

    func finish(with result: Result<(URLResponse, Data), CommonBundleSchemeHandler.Error>) {
        switch result {
        case .success(let (response, data)):
            didReceive(response)
            didReceive(data)
            didFinish()
        case .failure(let error):
            didFailWithError(error)
        }
    }
}
