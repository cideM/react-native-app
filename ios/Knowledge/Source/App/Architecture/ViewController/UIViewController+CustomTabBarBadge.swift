//
//  UIViewController+CustomTabBarBadge.swift
//  Knowledge
//
//  Created by CSH on 21.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UIViewController {

    private enum AssociatedObject {
        static var customTabBarBadgeKey: UInt8 = 0
        static var tabBarControllerObservationKey: UInt8 = 1
    }

    private var amboss_tabBarControllerObservation: NSKeyValueObservation? { // swiftlint:disable:this identifier_name
        get {
            objc_getAssociatedObject(self, &AssociatedObject.tabBarControllerObservationKey) as? NSKeyValueObservation
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.tabBarControllerObservationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var amboss_customTabBarBadge: UIView? { // swiftlint:disable:this identifier_name
        get {
            objc_getAssociatedObject(self, &AssociatedObject.customTabBarBadgeKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.customTabBarBadgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var amboss_customBadgeView: UIView? { // swiftlint:disable:this identifier_name
        get {
            amboss_customTabBarBadge
        }
        set {
            amboss_customTabBarBadge?.removeFromSuperview()
            if let newValue = newValue {
                amboss_setTabBarBadgeView(newValue)
            }
        }
    }

    private func amboss_setTabBarBadgeView(_ view: UIView) {
        defer {
            amboss_customTabBarBadge = view
        }

        guard tabBarController != nil else {
            amboss_tabBarControllerObservation = observe(\.parent, options: [.old, .new]) { [weak self] _, change in
                if change.newValue as? UITabBarController != nil {
                    DispatchQueue.main.async {
                        self?.amboss_tabBarControllerObservation = nil
                        self?.amboss_setTabBarBadgeView(view)
                    }
                }
            }
            return
        }

        guard let index = amboss_indexInTabBar,
            var tabBarButtons = tabBarController?.tabBar.subviews.filter({ $0.frame.minX != 0 }), // Filter out the background view
            tabBarButtons.count > index else {
                return
        }

        tabBarButtons.sort { lhs, rhs -> Bool in lhs.frame.minX < rhs.frame.minX } // sort by horizontal position

        let tabBarButton = tabBarButtons[index]
        guard let imageView = tabBarButton.subviews.first(where: { $0 is UIImageView }) else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(view)
        view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor, constant: imageView.frame.width / 2).isActive = true
        view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -imageView.frame.height / 2).isActive = true
    }

    private var amboss_indexInTabBar: Int? { // swiftlint:disable:this identifier_name
        guard let tabBarController = tabBarController else { return nil }
        return tabBarController.viewControllers?.firstIndex(of: self)
    }

}
