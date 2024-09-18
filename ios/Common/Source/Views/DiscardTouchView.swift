//
//  DiscardTouchView.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 21.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// A DiscardTouchView is a view that can be configured to discard all
/// touches that hit the view itself but don't hit any subviews
open class DiscardTouchView: UIView {

    /// Configures whether the view should discard all touches sent to it
    /// or to absorb them.
    ///
    /// default = true
    public var discardsTouches = true

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self && discardsTouches {
            return nil
        }
        return hitView
    }
}
