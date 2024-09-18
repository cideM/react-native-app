//
//  WebView.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 27.11.23.
//

import WebKit

public extension WKWebView {

    var isInspectableInDebugAndQABuilds: Bool {
        get {
            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
                return isInspectable
            } else {
                return false
            }
        }
        set { // swiftlint:disable:this unused_setter_value
            #if DEBUG
            // Info taken from here:
            // https://webkit.org/blog/13936/enabling-the-inspection-of-web-content-in-apps/
            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
                isInspectable = true
            }
            #endif
        }
    }
}
