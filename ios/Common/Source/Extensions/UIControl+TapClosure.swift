//
//  UIControl+TapClosure.swift
//  Common
//
//  Created by CSH on 01.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UIControl: TapClosure {
    public var touchUpInsideActionClosure: Action? {
        get {
            tapClosure
        }
        set {
            tapClosure = newValue
            addTarget(self, action: #selector(didTouchUpInside(sender:)), for: .touchUpInside)
        }
    }

    @objc func didTouchUpInside(sender: Any) {
        touchUpInsideActionClosure?()
    }
}
