//
//  SearchPresentationTransitioningManager.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 10.08.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

public final class SearchPresentationTransitioningManager: NSObject, UIViewControllerTransitioningDelegate {
    private let rootViewController: RootViewController
    private var sourceView: UIView? {
        switch rootViewController.selectedIndex {
        case 0:
            let navigationController = rootViewController.children[0] as? UINavigationController
            if navigationController?.viewControllers.count == 1 {
                let dashboardViewController = navigationController?.children.first as? DashboardViewController
                return dashboardViewController?.header.searchBar?.searchTextField
            } else if let viewController = navigationController?.topViewController as? ContentListTableViewController {
                return viewController.searchBar.searchTextField
            } else if let viewController = navigationController?.topViewController as? ContentListCollectionViewController {
                return viewController.searchBar.searchTextField
            } else {
                return nil
            }
        case 1:
            let navigationController = rootViewController.children[1] as? UINavigationController
            if navigationController?.viewControllers.count == 1 {
                let libraryViewController = navigationController?.children.first as? LibraryViewController
                return libraryViewController?.navigationItem.searchController?.searchBar.searchTextField
            } else {
                return nil
            }
        default: return nil
        }
    }

    init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        super.init()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = dismissed as? UINavigationController,
              let searchViewController = navigationController.children.first as? SearchViewController else { return nil }
        return SearchPresentationAnimationController(isPresentation: false, sourceView: sourceView, searchViewController: searchViewController)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationController = presented as? UINavigationController,
              let searchViewController = navigationController.children.first as? SearchViewController else { return nil }
        return SearchPresentationAnimationController(isPresentation: true, sourceView: sourceView, searchViewController: searchViewController)
    }
}

public final class SearchPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPresentation: Bool
    private let sourceView: UIView?
    private let searchViewController: SearchViewController

    init(isPresentation: Bool, sourceView: UIView?, searchViewController: SearchViewController) {
        self.isPresentation = isPresentation
        self.sourceView = sourceView
        self.searchViewController = searchViewController
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.2
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from)?.view,
              let toView = transitionContext.viewController(forKey: .to)?.view else {
            transitionContext.completeTransition(true)
            return
        }

        let presentedView = isPresentation ? toView : fromView

        if isPresentation {
            transitionContext.containerView.addSubview(presentedView)
            presentedView.alpha = 0.0
        }

        if let sourceView = sourceView {
            if isPresentation {
                animate(from: sourceView, to: searchViewController.searchBar.searchTextField, in: transitionContext.containerView, duration: transitionDuration(using: transitionContext))
            } else {
                animate(from: searchViewController.searchBar.searchTextField, to: sourceView, in: transitionContext.containerView, duration: transitionDuration(using: transitionContext))
            }
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0) {
            presentedView.alpha = self.isPresentation ? 1.0 : 0.0
        } completion: { _ in
            if !self.isPresentation {
                presentedView.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
    }

    private func animate(from: UIView?, to: UIView?, in context: UIView, duration: TimeInterval) {
        guard let from = from,
              let to = to,
              let fromSnapshot = from.snapshotView(afterScreenUpdates: true),
              let toSnapshot = to.snapshotView(afterScreenUpdates: true),
              let fromSuperview = from.superview,
              let toSuperview = to.superview else { return }

        var fromFrame = from.frame
        fromFrame.origin = fromSuperview.convert(fromFrame.origin, to: context)

        var toFrame = to.frame
        toFrame.origin = toSuperview.convert(toFrame.origin, to: context)

        fromSnapshot.alpha = 1.0
        toSnapshot.alpha = 0.0
        from.alpha = 0.0
        to.alpha = 0.0
        fromSnapshot.frame = fromFrame
        toSnapshot.frame = fromFrame
        context.addSubview(fromSnapshot)
        context.addSubview(toSnapshot)

        UIView.animate(withDuration: duration, delay: 0) {
            fromSnapshot.frame = toFrame
            toSnapshot.frame = toFrame
            fromSnapshot.alpha = 0.0
            toSnapshot.alpha = 1.0
            from.alpha = 0.0
        } completion: { _ in
            from.alpha = 1.0
            to.alpha = 1.0
            fromSnapshot.removeFromSuperview()
            toSnapshot.removeFromSuperview()
        }
    }

}
