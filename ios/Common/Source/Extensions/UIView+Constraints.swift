//
//  UIView+Constraints.swift
//  Common
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public extension UIView {

    /// Fits this view to the edges of another view
    ///
    /// - Parameter view: The UIView to which edges this view should be contrainted
    /// - Parameter priority: The UILayoutPriority for all the constraints created. default: `.required`
    /// - Returns: The constraints that have been set
    @discardableResult func constrainEdges(to view: UIView, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        constraints.append(view.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(view.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(view.widthAnchor.constraint(equalTo: widthAnchor))
        constraints.append(view.heightAnchor.constraint(equalTo: heightAnchor))
        constraints.forEach { $0.priority = priority }
        constraints.forEach { $0.isActive = true }
        return constraints
    }

    /// Fits this view to the edges of the safeAreaLayoutGuide another view
    ///
    /// - Parameter layoutGuide: The UILayoutGuide to which anchors this view should be contrainted
    /// - Parameter priority: The UILayoutPriority for all the constraints created. default: `.required`
    /// - Returns: The constraints that have been set
    @discardableResult func constrainEdges(to layoutGuide: UILayoutGuide, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        constraints.append(topAnchor.constraint(equalTo: layoutGuide.topAnchor))
        constraints.append(trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor))
        constraints.append(leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor))
        constraints.append(bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor))
        constraints.forEach { $0.priority = priority }
        constraints.forEach { $0.isActive = true }
        return constraints
    }

    /// Add a constraint from this view to another view
    ///
    /// - parameter attribute: A NSLayoutAttribute layout attribute for this view
    /// - parameter to: optional Target object
    /// - parameter toAttribute: A NSLayoutAttribute for the target object
    /// - parameter relation: A NSLayoutRelation (default = .equal)
    /// - parameter multiplier: The multiplier (default = 1)
    /// - parameter constant: The constant value (default = 0)
    /// - Returns: The constraint that has been set
    @discardableResult func constrain(_ attribute: NSLayoutConstraint.Attribute, to: Any?, attribute toAttribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, multiplier: CGFloat = 1, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        NSLayoutConstraint.activate([constraint])
        return constraint
    }

    /// Fits this view to the edges of another view
    ///
    /// - Parameter view: The UIView to which edges this view should be contrainted
    /// - Parameter priority: The UILayoutPriority for all the constraints created. default: `.required`
    /// - Returns: The constraints that have been set
    @discardableResult func constrain(to view: UIView, priority: UILayoutPriority = .required, margins: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margins.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margins.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: margins.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margins.bottom)
        ]
        constraints.forEach { $0.priority = priority }
        constraints.forEach { $0.isActive = true }
        return constraints
    }
}
