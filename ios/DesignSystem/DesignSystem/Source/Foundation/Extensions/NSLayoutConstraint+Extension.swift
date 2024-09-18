//
//  NSLayoutConstraint+Extension.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public extension NSLayoutConstraint {

    func with(priority: UILayoutPriority) -> Self {
        self.priority = priority

        return self
    }

    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])

        return newConstraint
    }
}

public extension UILayoutPriority {
    static var almostRequired = UILayoutPriority(rawValue: 999)
    static var `default` = UILayoutPriority(rawValue: 750)

}
