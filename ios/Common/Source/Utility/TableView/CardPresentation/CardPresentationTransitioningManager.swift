//
//  CardPresentationTransitioningManager.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 19.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

public final class CardPresentationTransitioningManager: NSObject, UIViewControllerTransitioningDelegate {

    private var cardPresentationController: CardPresentationController?
    private let edge: SlideInTransitionEdge
    private let fullScreenWidth: Bool
    public init(edge: SlideInTransitionEdge, fullScreenWidth: Bool = true) {
        self.edge = edge
        self.fullScreenWidth = fullScreenWidth
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        cardPresentationController = CardPresentationController(presentedViewController: presented, presenting: presenting, edge: edge, fullScreenWidth: fullScreenWidth)
        return cardPresentationController
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presentationController = cardPresentationController else {
            return nil
        }
        return SlideInPresentationAnimator(edge: edge, isPresentation: true, interactive: presentationController.isBeingDismissedInteractively)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presentationController = cardPresentationController else {
            return nil
        }
        return SlideInPresentationAnimator(edge: edge, isPresentation: false, interactive: presentationController.isBeingDismissedInteractively)
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let presentationController = cardPresentationController else {
            return nil
        }
        return presentationController.isBeingDismissedInteractively ? presentationController.interactiveController : nil
    }
}
