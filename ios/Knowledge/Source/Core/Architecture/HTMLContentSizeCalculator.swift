//
//  HTMLContentSizeCalculator.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 16.03.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import WebKit

/// @mockable
protocol HTMLContentSizeCalculatorType {
    /// Calculates the size of the content of an HTML document.
    /// - Parameters:
    ///   - htmlDocument: The HTML document you want to calculate its content size.
    ///   - width: The width of the area to show the HTML content in.
    ///   - completion: A completion block that will contain the calculated size.
    func calculateSize(for htmlDocument: HtmlDocument, width: CGFloat, completion: @escaping (CGSize) -> Void)

    /// Calculates the size of the content of an HTML document.
    /// - Parameters:
    ///   - url: The URL of the HTML document you want to calculate its content size.
    ///   - width: The width of the area to show the HTML content in.
    ///   - completion: A completion block that will contain the calculated size.
    func calculateSize(for url: URL, width: CGFloat, completion: @escaping (CGSize) -> Void)
}

extension HTMLContentSizeCalculatorType {
    func calculateSize(for htmlDocument: HtmlDocument, completion: @escaping (CGSize) -> Void) {
        calculateSize(for: htmlDocument, width: UIScreen.main.bounds.width, completion: completion)
    }

    func calculateSize(for url: URL, completion: @escaping (CGSize) -> Void) {
        calculateSize(for: url, width: UIScreen.main.bounds.width, completion: completion)
    }
}

final class HTMLContentSizeCalculator: NSObject, HTMLContentSizeCalculatorType {

    private let webView: WKWebView
    private var completion: ((CGSize) -> Void)?

    init(config: WKWebViewConfiguration? = nil) {
        let userScript = WKUserScript(source: Self.calculateContentHeightFunctionDeclaration, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        let configuration = config ?? WKWebViewConfiguration()
        configuration.userContentController = userContentController

        webView = WKWebView(frame: .zero, configuration: configuration)

        super.init()

        webView.navigationDelegate = self
    }

    func calculateSize(for htmlDocument: HtmlDocument, width: CGFloat = UIScreen.main.bounds.width, completion: @escaping (CGSize) -> Void) {
        self.completion = completion

        webView.frame = CGRect(x: 0, y: 0, width: width, height: 1)

        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        webView.loadHTMLString(htmlDocument.asHtml, baseURL: baseURL)
    }

    func calculateSize(for url: URL, width: CGFloat = UIScreen.main.bounds.width, completion: @escaping (CGSize) -> Void) {
        self.completion = completion

        self.webView.frame = CGRect(x: 0, y: 0, width: width, height: 1)

        self.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent().deletingLastPathComponent())
    }
}

extension HTMLContentSizeCalculator {
    /// The name of the JavaScript function responsible for the calculation of content height.
    private static let calculateContentHeightFunction = "calculateContentHeight();"

    /// The body of the JavaScript function responsible for the calculation of content height.
    private static let calculateContentHeightFunctionDeclaration = """
        function calculateContentHeight() {
            var body = document.body;
            var html = document.documentElement;
            return Math.min(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
        }
    """
}

extension HTMLContentSizeCalculator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
        webView.evaluateJavaScript(Self.calculateContentHeightFunction) { [weak self] result, error in
            guard let self = self, let completion = self.completion else { return }

            guard error == nil else {
                return completion(.zero)
            }

            guard let webContentHeight = result as? Float else {
                return completion(.zero)
            }

            let size = CGSize(width: self.webView.frame.width, height: CGFloat(webContentHeight))
            completion(size)
        }
    }
}
