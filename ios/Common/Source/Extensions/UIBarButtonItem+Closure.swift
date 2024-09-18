//
//  UIBarButtonItem+Closure.swift
//  Common
//
//  Created by CSH on 11.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    typealias UIBarButtonItemActionClosure = (UIBarButtonItem) -> Void

    private enum AssociatedObject {
        static var key: UInt8 = 0
    }

    private var actionClosure: UIBarButtonItemActionClosure? {
        get {
            objc_getAssociatedObject(self, &AssociatedObject.key) as? UIBarButtonItemActionClosure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTap(sender:))
        }
    }

    @objc func didTap(sender: Any) {
        actionClosure?(self)
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, actionClosure: @escaping UIBarButtonItemActionClosure) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.actionClosure = actionClosure
    }

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionClosure: @escaping UIBarButtonItemActionClosure) {
        self.init(image: image, style: style, target: nil, action: nil)
        self.actionClosure = actionClosure
    }

    convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, actionClosure: @escaping UIBarButtonItemActionClosure) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        self.actionClosure = actionClosure
    }
}
