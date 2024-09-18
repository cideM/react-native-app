//
//  TapClosure.swift
//  Common
//
//  Created by Cornelius Horstmann on 28.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public protocol TapClosure: NSObjectProtocol {
    typealias Action = () -> Void

    var tapClosure: Action? { get set }
}

private enum TapClosureAssociatedObject {
    static var touchUpInsideActionClosureKey: UInt8 = 0
}

public extension TapClosure {
    var tapClosure: Action? {
        get {
            objc_getAssociatedObject(self, &TapClosureAssociatedObject.touchUpInsideActionClosureKey) as? Action
        }
        set {
            objc_setAssociatedObject(self, &TapClosureAssociatedObject.touchUpInsideActionClosureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
