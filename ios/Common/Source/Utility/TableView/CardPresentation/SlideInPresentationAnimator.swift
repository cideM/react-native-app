//
//  SlideInPresentationAnimator.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 19.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let edge: SlideInTransitionEdge
    private let duration: TimeInterval
    private let interactive: Bool
    private let isPresentation: Bool

    init(edge: SlideInTransitionEdge, duration: TimeInterval = 0.3, isPresentation: Bool, interactive: Bool) {
        self.edge = edge
        self.duration = duration
        self.isPresentation = isPresentation
        self.interactive = interactive
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        guard let viewController = transitionContext.viewController(forKey: key) else { return }

        if isPresentation {
            transitionContext.containerView.addSubview(viewController.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: viewController)
        var dismissedTransform: CGAffineTransform = .identity

        switch edge {
        case .left:
            dismissedTransform = CGAffineTransform(translationX: -presentedFrame.width, y: 0)
        case .right:
            dismissedTransform = CGAffineTransform(translationX: +presentedFrame.width, y: 0)
        case .top:
            dismissedTransform = CGAffineTransform(translationX: 0, y: -presentedFrame.height)
        case .bottom:
             dismissedTransform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
        }

        viewController.view.transform = isPresentation ? dismissedTransform : .identity

        let animationDuration = transitionDuration(using: transitionContext)
        let options: UIView.AnimationOptions = interactive ? [.curveLinear] : [.curveEaseInOut]
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: options,
            animations: { [isPresentation] in viewController.view.transform = isPresentation ? .identity : dismissedTransform },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
