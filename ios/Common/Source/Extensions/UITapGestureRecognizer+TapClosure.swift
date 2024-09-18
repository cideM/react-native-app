//
//  UITapGestureRecognizer+TapClosure.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 14.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer: TapClosure {
    public var onTap: Action? {
        get {
            tapClosure
        }
        set {
            tapClosure = newValue
            addTarget(self, action: #selector(onTap(sender:)))
        }
    }

    @objc func onTap(sender: Any) {
        onTap?()
    }
}
