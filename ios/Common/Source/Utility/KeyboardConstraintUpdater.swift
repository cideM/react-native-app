//
//  KeyboardConstraintUpdater.swift
//  Common
//
//  Created by CSH on 31.01.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// The KeyboardConstraintUpdater observes the keyboard notifications and will modify constraint
/// constants based on showing, hiding or resizing the keyboard.
public final class KeyboardConstraintUpdater {

    private var constraints: [NSLayoutConstraint]
    private weak var rootView: UIView?
    public var isEnabled = true

    public init(rootView: UIView, constraints: [NSLayoutConstraint] = []) {
        self.rootView = rootView
        self.constraints = constraints
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    public func add(_ addingConstraints: [NSLayoutConstraint]) {
        self.constraints.append(contentsOf: addingConstraints)
    }

    public func remove(_ removingConstraints: [NSLayoutConstraint]) {
        self.constraints = self.constraints.filter { constraint in
            !removingConstraints.contains(constraint)
        }
    }

    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        update(constraints, from: notification)
    }

    private func update(_ constraints: [NSLayoutConstraint], from notification: NSNotification) {
        guard isEnabled else { return }
        guard let userInfo = notification.userInfo,
            let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIView.AnimationCurve(rawValue: curveValue),
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyWindow = UIApplication.keyWindow else { return }

        let intersection = keyWindow.frame.intersection(keyboardFrameEnd)
        let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))

        for constraint in constraints {
            constraint.constant = -intersection.height
        }

        UIView.animate(withDuration: duration, delay: 0.0, options: [options], animations: { [weak self] () in
            self?.rootView?.layoutIfNeeded()
        }, completion: nil)
    }
}
