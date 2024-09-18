//
//  WebViewPresenterType.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 11.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

public protocol WebViewPresenterType: AnyObject {
    var view: WebViewControllerType? { get set }
    func failedToLoad(with error: Error)
    func canNavigate(to url: URL) -> Bool
    func openExternally(url: URL)
}

public extension WebViewPresenterType {
    func canNavigate(to url: URL) -> Bool {
        // If the link has a custom scheme, the webview cannot navigate to it
        if let scheme = url.scheme,
           ["http", "https", "about"].contains(scheme) == false {
            return false
        }
        return true
    }

    func openExternally(url: URL) {
        UIApplication.shared.open(url)
    }
}
