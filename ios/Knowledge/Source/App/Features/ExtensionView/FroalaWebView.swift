//
//  FroalaWebView.swift
//  Knowledge
//
//  Created by CSH on 20.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import WebKit

class FroalaWebView: WKWebView {
    var accessoryView: UIView?

    override var inputAccessoryView: UIView? {
        accessoryView
    }

}
