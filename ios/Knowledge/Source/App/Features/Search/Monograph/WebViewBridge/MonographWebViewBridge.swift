//
//  MonographWebViewBridge.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 09.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import WebKit

// MONOGRAPHS-WIP: Everything in here is preliminary ...
// See here for the spec in progress: https://www.notion.so/amboss1/JS-Bridge-Pharma-Draft-d0ed27aec7eb402996d0d5c3578c3a51

protocol MonographWebViewBridgeDelegate: AnyObject {
    func bridge(didReceive event: MonographWebViewBridge.Event)
    func bridge(didReceive analyticsEvent: MonographWebViewBridge.AnalyticsEvent)
    func bridge(didFail error: MonographWebViewBridge.Error)
}

final class MonographWebViewBridge: NSObject {

    enum MonographEvent: String, CaseIterable {
        case uiEvent = "onUIEvent"
        case analyticsEvent = "onAnalyticsEvent"
    }

    weak var delegate: MonographWebViewBridgeDelegate?
    let webViewConfiguration = WKWebViewConfiguration()

    required init(delegate: MonographWebViewBridgeDelegate) {
        super.init()
        self.delegate = delegate

        var remappingJS = "window.mobile = {};\n"
        for event in MonographEvent.allCases {
            // This must be executed BEFORE the assignment to "remappingScript" because:
            // "onUiEvent", "onAnalyticsEvent" are used in the script and hence must be available
            self.webViewConfiguration.userContentController.add(self, name: event.rawValue)

            // This reroutes functions invoked on "mobile." into "window.webkit.messageHandlers"
            // so that they invoke userContentController(:, didReceive:) in WKScriptMessageHandler
            // Notes:
            // window.mobile = {}; <- This can not be removed,
            // If you do: window.mobile.\(event.rawValue) will not have a valid definition in the webpage context
            remappingJS += """
                        window.mobile.\(event.rawValue) = function(...args) {
                            window.webkit.messageHandlers.\(event.rawValue).postMessage(args)
                        };\n
                        """
        }

        let remappingScript = WKUserScript(source: remappingJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webViewConfiguration.userContentController.addUserScript(remappingScript)
    }
}

extension MonographWebViewBridge: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let monographEvent = MonographEvent(rawValue: message.name) else {
            delegate?.bridge(didFail: .parsingError)
            return
        }

        guard let array = message.body as? [String],
              let stringifiedObject = array.first,
              let data = stringifiedObject.data(using: .utf8),
              let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
        else {
            delegate?.bridge(didFail: .parsingError)
            return
        }

        switch monographEvent {
        case MonographEvent.uiEvent:
            do {
                let event = try Event(dictionary: jsonDictionary)
                delegate?.bridge(didReceive: event)
            } catch let error as MonographWebViewBridge.Error {
                delegate?.bridge(didFail: error)
            } catch {
                assertionFailure()
            }
        case MonographEvent.analyticsEvent:
            do {
                let analyticsEvent = try AnalyticsEvent(dictionary: jsonDictionary)
                delegate?.bridge(didReceive: analyticsEvent)
            } catch let error as MonographWebViewBridge.Error {
                delegate?.bridge(didFail: error)
            } catch {
                assertionFailure()
            }
        }
    }
}
