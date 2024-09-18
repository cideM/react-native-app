//
//  WebViewBridge.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import WebKit

enum BridgeError: Error {
    case bridgeReportedError(Error)
    case parsing(Error?)
}

final class WebViewBridge: NSObject {

    private weak var delegate: WebViewBridgeDelegate?
    let webViewConfiguration: WKWebViewConfiguration

    private var postInitCalls: [Call] = []
    private var didInit = false

    required init(delegate: WebViewBridgeDelegate) {
        self.delegate = delegate
        self.webViewConfiguration = WKWebViewConfiguration()
        self.webViewConfiguration.userContentController = WKUserContentController()
        super.init()

        for name in Callbackname.allCases {
            // add message handlers for all callbacks
            self.webViewConfiguration.userContentController.add(self, name: name.rawValue)
        }

        let androidRemappingUserscript = WKUserScript(source: androidRemappingUserscriptString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webViewConfiguration.userContentController.addUserScript(androidRemappingUserscript)
    }

    /// This is the javascript string, that maps the "window.android.<callback>" calls to the iOS compatible javascript call,
    /// which we can intercept and parse.
    private lazy var androidRemappingUserscriptString: String = {
        var string = "window.android = {}\n"
        for name in Callbackname.allCases {
            string += """
            window.android.\(name) = function(...args) {
                \(self.defaultJSResponse(for: name))
                window.webkit.messageHandlers.\(name.rawValue).postMessage(args)
            }\n
            """
        }
        return string
    }()

    /// This function defines default responses that are immediately sent to the WebView once a specific callback is received.
    /// - Parameter callback: The Callback received from a webview
    private func defaultJSResponse(for callback: Callbackname) -> String {
        switch callback {
        case .`init`:
            return """
            Amboss.LearningCard.showFeedback();
            Amboss.LearningCard.setCapabilities(["image_gallery"]);
            """
        default: return ""
        }
    }

    /// This function makes sure that every call that is called before the webView is initialized to be stored in the `postInitCalls` array.
    /// Every call in the `postInitCalls` array will get executed once the `.init` callback is received.
    /// Before a new webView is loaded the `resetState` function is called.
    ///
    /// Usually the webviews bridge is initialised when the webview is presented -> hence "init" callback is triggered.
    /// An edge case where this might not happen is in case the webview is supposed to be opened via a deeplink.
    /// eg: https://www.amboss.com/de/app2web/library/wS0hbf/_6c5nW0/Txa6D5?p=iOS&pv=14.4&an=broccoli&av=v1.6.6b1&token=8331573c8cda199df3cd3cc379df004c
    ///
    /// - Parameters:
    ///   - call: The call to get executed.
    ///   - webView: The webView that is loaded
    ///   - completion: A completion handler that will be called with result.
    func call(_ call: Call, on webView: WKWebView, completion: @escaping (Result<Void, BridgeError>) -> Void = { _ in }) {
        guard didInit else {
            postInitCalls.append(call)
            return
        }
        webView.evaluateJavaScript(call.jsCall) { _, error in
            if let error = error {
                return completion(.failure(.bridgeReportedError(error)))
            }
            completion(.success(()))
        }
    }

    func query<T: Codable>(_ query: Query<T>, on webView: WKWebView, completion: @escaping (Result<T, BridgeError>) -> Void = { _ in }) {
        webView.evaluateJavaScript(query.jsQuery) { result, error in
            if let error = error {
                return completion(.failure(.bridgeReportedError(error)))
            }

            if let result = result, let resultString = result as? String, let resultData = resultString.data(using: .utf8) {
                do {
                    completion(.success(try JSONDecoder().decode(query.expectedResultType, from: resultData)))
                } catch {
                    completion(.failure(.parsing(error)))
                }
            } else {
                completion(.failure(.parsing(nil)))
            }
        }
    }

    /// This function is called before a new webView is loaded.
    func resetState() {
        postInitCalls = []
        didInit = false
    }
}

extension WebViewBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let callback = Callback(name: message.name, arguments: message.body as? [Any] ?? [Any]()) else {
            assertionFailure("unexpected callback")
            return
        }

        switch callback {
        case .`init`:
            didInit = true
            if let webView = message.webView {
                for call in postInitCalls {
                    self.call(call, on: webView)
                }
                postInitCalls = []
            }
        default:
            break
        }

        delegate?.webViewBridge(bridge: self, didReceiveCallback: callback)
    }
}
