//
//  SectionedNavigationController.swift
//  Knowledge
//
//  Created by CSH on 12.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// A SectionedNavigationController can be used to keep track of just a subset of ViewControllers
/// added to a UINavigationController. This information can then be used to pop just this subset.
final class SectionedNavigationController: NSObject {

    let navigationController: UINavigationController

    private var pushedViewControllers: [UIViewController] = []
    private(set) weak var presentedViewController: UIViewController?

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
        pushedViewControllers.append(viewController)
    }

    private func dismissAllViewControllers(animated: Bool, completion: @escaping () -> Void) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: animated, completion: completion)
        } else {
            completion()
        }
    }

    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        /*
         WORKAROUND:
         Sometimes, the presentedViewController is not in the view hierarchy anymore but it is still retained by a different class.
         Hence, we need to make sure that the navigationController here is actually presenting something before asking the presentedViewController to present the view controller we want to present. If we didn't do that, and the presentedViewController was in memory but not in the view hierarchy, the presentation will fail and an error will be logged to the console saying that we tried to present on a view controller that is not in the view hierarchy anymore.
         This happens for example when the LearningCardCoordinator presents a snippet. The snippet is presented using a CardTransition instance that keeps a strong reference to the SnippetViewController instance even after it's dismissed (we need to keep that strong reference so that the cardTransition also handles the dismissal of the snippet).
         This also happens in cases where there is a retain cycle that is keeping a dismissed controller in memory for a longer time (and for this, we need to add an assertion here in the future in order to catch this kinds of bugs).
         */
        if let presentedViewController = presentedViewController, navigationController.presentedViewController != nil {
            let topMostViewController = UIViewController.topMost(of: presentedViewController)
            topMostViewController.present(viewController, animated: animated, completion: completion)
        } else {
            navigationController.present(viewController, animated: animated, completion: completion)
            presentedViewController = viewController
        }
    }

    /// This is general method to take care of all things that were presented modally OR pushed to the navigation stack
    /// - Parameter animated: Should the change be animated or not
    func dismissAndPopAll(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismissAllViewControllers(animated: animated) {
            completion?()
        }
    }

    func dismissPresented(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedViewController = presentedViewController else { completion?(); return }

        let topMostViewController = UIViewController.topMost(of: presentedViewController)
        topMostViewController.dismiss(animated: animated, completion: completion)
    }

    /// Pops to the first managed ViewController
    /// - Parameter animated: Should the change be animated or not
    func popToRoot(animated: Bool) {
        dismissPresented(animated: animated)
        guard let rootViewController = navigationController.viewControllers.first(where: { pushedViewControllers.contains($0) }) else {
            return // No ViewController is displayed by this SectionedNavigationController, nothing to pop
        }
        let filteredViewControllers = navigationController.viewControllers.filter { !pushedViewControllers.contains($0) }
        let newViewControllers = filteredViewControllers + [rootViewController]
        navigationController.setViewControllers(newViewControllers, animated: animated)
        pushedViewControllers = [rootViewController]
    }
}

extension SectionedNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            pushedViewControllers.contains(fromViewController) else {
            return
        }
        pushedViewControllers = pushedViewControllers.filter { navigationController.viewControllers.contains($0) }
    }
}

// WORKAROUND: In the pocket guides feature we need to set the
// interactivePopGestureRecognizer.delegate and handle some
// custom logic. This means when the user exits the pocket
// guide the delegate becomes == nil for the dashboard's navVC.
// => We need to set the implement the delegate here to
// enable the gesture again.
extension SectionedNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == navigationController.interactivePopGestureRecognizer else {
            return true // default value will disable the gesture
        }

        return navigationController.viewControllers.count > 1
    }
}
