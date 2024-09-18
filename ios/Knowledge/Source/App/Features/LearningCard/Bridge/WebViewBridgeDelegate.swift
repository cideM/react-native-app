//
//  WebViewBridgeDelegate.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

protocol WebViewBridgeDelegate: AnyObject {
    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback)
}
