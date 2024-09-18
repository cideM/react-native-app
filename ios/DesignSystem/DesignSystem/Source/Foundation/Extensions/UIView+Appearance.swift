//
//  UIView+Appearance.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 01.06.23.
//

import UIKit

public extension UIView {
    func apply(cornerRadius: CGFloat, maskedCorners: CACornerMask? = nil) {
        layer.apply(cornerRadius: cornerRadius, maskedCorners: maskedCorners)
    }

    @discardableResult
    func apply(elevation level: ElevationLevel) -> ElevatedView? {
        guard let parentView = superview else { return nil }
        let elevation = level.rawValue
        let elevatedView = ElevatedView(elevation: elevation,
                                      cornerRadius: self.layer.cornerRadius)
        parentView.insertSubview(elevatedView, belowSubview: self)
        elevatedView.pin(to: self)
        return elevatedView
    }
}

extension CALayer {

    func apply(cornerRadius: CGFloat, maskedCorners: CACornerMask? = nil) {
        masksToBounds = true
        self.cornerRadius = cornerRadius
        self.cornerCurve = .continuous

        if let maskedCorners = maskedCorners {
            self.maskedCorners = maskedCorners
        }
    }
}
