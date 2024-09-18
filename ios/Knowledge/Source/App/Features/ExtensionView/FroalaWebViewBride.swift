//
//  FroalaWebViewBride.swift
//  Knowledge
//
//  Created by Silvio Bulla on 14.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import WebKit

final class FroalaWebViewBride {

    let webViewConfiguration: WKWebViewConfiguration

    init() {
        self.webViewConfiguration = WKWebViewConfiguration()
        self.webViewConfiguration.userContentController = WKUserContentController()
    }

    func call<T: Decodable>(_ call: Call<T>, on webView: WKWebView, completion: @escaping (Result<String?, Error>) -> Void = { _ in }) {
        webView.evaluateJavaScript(call.jsCall) { result, error in
            if let result = result {
                if call.expectedResultType != nil {
                    if let resultString = result as? String {
                        completion(.success(resultString))
                    }
                } else {
                    completion(.success(nil))
                }
        } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
}

extension FroalaWebViewBride {

    struct Call<T: Codable> {
        let jsCall: String
        let expectedResultType: T.Type?
    }

    enum Calls {
        static func setText(extensionContent: String) -> Call<String> {
            // 1) Create a JSON data containing "[content]"
            let jsonData = try! JSONSerialization.data(withJSONObject: [extensionContent], options: []) // swiftlint:disable:this force_try
            // 2) Create a string from the data
            let jsonString = String(data: jsonData, encoding: .utf8)! // swiftlint:disable:this force_unwrapping
            // 3) Remove the enclosing array and string quote characters ( `["` and `"]` )
            let escapedString = jsonString[jsonString.index(jsonString.startIndex, offsetBy: 2) ..< jsonString.index(jsonString.endIndex, offsetBy: -2)]

            return Call(jsCall: "$(\"#edit\").editable(\"setHTML\", \"\(escapedString)\");", expectedResultType: String.self)
        }
        static func toggleBold() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'bold');", expectedResultType: String.self) }
        static func toggleItalic() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'italic');", expectedResultType: String.self) }
        static func toggleUnderline() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'underline');", expectedResultType: String.self) }
        static func undo() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'undo');", expectedResultType: String.self) }
        static func redo() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'redo');", expectedResultType: String.self) }
        static func insertOrderedList() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'insertOrderedList');", expectedResultType: String.self) }
        static func insertUnorderedList() -> Call<String> { Call(jsCall: "$('#edit').editable('exec', 'insertUnorderedList');", expectedResultType: String.self) }
        static func getExtensionHtml() -> Call<String> { Call(jsCall: "$('#edit').editable('getHTML');", expectedResultType: String.self) }
    }
}
