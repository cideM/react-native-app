//
//  UIViewController+TopMost.swift
//  Knowledge DE
//
//  Created by Vedran Burojevic on 09/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UIViewController {

    static var topMostViewController: UIViewController? {
        let currentWindows = UIApplication.shared.windows
        var rootViewController: UIViewController?

        for window in currentWindows {
            if let windowRootViewController = window.rootViewController, window.isKeyWindow {
                rootViewController = windowRootViewController
                break
            }
        }

        if let rootViewController = rootViewController {
            return topMost(of: rootViewController)
        } else {
            return nil
        }
    }

    /// Returns the top most view controller from given view controller's stack.
    static func topMost(of viewController: UIViewController) -> UIViewController {
        // Presented view controller
        if let presentedViewController = viewController.presentedViewController {
            return self.topMost(of: presentedViewController)
        }

        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }

        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }

        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1, let first = pageViewController.viewControllers?.first {
            return self.topMost(of: first)
        }

        // Child view controller
        for subview in viewController.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }

        return viewController
    }

    static func openViewControllerAsTopMost(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let topMostViewController = UIViewController.topMostViewController else { return }

        let presentingViewController = topMostViewController.presentingViewController
        if let presentingViewController = presentingViewController, (topMostViewController.navigationController ?? topMostViewController).isBeingDismissed {
            presentingViewController.dismiss(animated: true) {
                presentingViewController.present(viewController, animated: true, completion: completion)
            }
        } else {
            topMostViewController.present(viewController, animated: true, completion: completion)
        }
    }
}
