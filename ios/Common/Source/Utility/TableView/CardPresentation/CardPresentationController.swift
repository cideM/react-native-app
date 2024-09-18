//
//  CardPresentationController.swift
//  Common
//
//  Created by CSH on 25.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class CardPresentationController: UIPresentationController {
    private let cardEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let cardCornerRadius: CGFloat = 16

    private(set) var isBeingDismissedInteractively = false
    private(set) var interactiveController: PanGestureInteractionController?
    private let edge: SlideInTransitionEdge
    private let fullScreenWidth: Bool

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme.cardPresentationDimmingViewBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapDimmingView))
        )
        return view
    }()

    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return presentedViewRect(containerSize: containerView.bounds.size)
    }

    public init(presentedViewController: UIViewController, presenting: UIViewController?, edge: SlideInTransitionEdge, fullScreenWidth: Bool = true) {
        self.edge = edge
        self.fullScreenWidth = fullScreenWidth
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView, let coordinator = presentingViewController.transitionCoordinator else { return }

        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)
        dimmingView.constrainEdges(to: containerView)
        dimmingView.addSubview(presentedViewController.view)

        // Before beginning a transition we need to make sure that 1- the view has its frame set to the frame we expect, 2- the view has laid out its subviews after the new frame was set and 3- the expected frame is recalculated again after all the subviews are laid out to make sure we have the right frame size.
        presentedViewController.view.frame = presentedViewRect(containerSize: containerView.frame.size)
        presentedViewController.view.layoutIfNeeded()
        presentedViewController.view.frame = presentedViewRect(containerSize: containerView.frame.size)

        presentedViewController.view.layer.cornerRadius = cardCornerRadius
        presentedViewController.view.layer.masksToBounds = true

        switch edge {
        case .top:
            presentedViewController.view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .bottom:
            presentedViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .left:
            presentedViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .right:
            presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }

        coordinator.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.alpha = 1
        }, completion: nil)
    }

    override public func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.alpha = 0
        }, completion: nil)
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }

        guard let presentedView = presentedView else {
            return
        }

        interactiveController = PanGestureInteractionController(view: presentedView, edge: edge)
        interactiveController?.didBeginPanningHandler = { [weak self] in
            self?.isBeingDismissedInteractively = true
            self?.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        isBeingDismissedInteractively = false
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        guard let containerView = containerView, container === presentedViewController else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let expectedFrame = self.presentedViewRect(containerSize: containerView.frame.size)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .beginFromCurrentState) {
                self.presentedViewController.view.frame = expectedFrame
            }
        }
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let expectedFrame = presentedViewRect(containerSize: size)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.presentedViewController.view.frame = expectedFrame
        }, completion: nil)
    }

    private func presentedViewRect(containerSize: CGSize) -> CGRect {
        presentedViewController.view.layoutIfNeeded()

        let preferredWidth = presentedViewController.preferredContentSize.width
        var preferredHeight = presentedViewController.preferredContentSize.height

        if preferredHeight >= UIScreen.main.bounds.height - 50 {
            preferredHeight = UIScreen.main.bounds.height - 50
        }

        let height = min(containerSize.height, preferredHeight)
        let width = min(containerSize.width, preferredWidth)

        var finalWidth = containerSize.width
        if !fullScreenWidth {
            finalWidth = width
        }

        switch edge {
        case .left:
            return CGRect(x: 0, y: 0, width: width, height: containerSize.height)
        case .right:
            return CGRect(x: containerSize.width - width, y: 0, width: width, height: containerSize.height)
        case .top:
            return CGRect(x: (containerSize.width - finalWidth) / 2.0, y: 0, width: finalWidth, height: height).inset(by: cardEdgeInsets)
        case .bottom:
            return CGRect(x: (containerSize.width - finalWidth) / 2.0, y: containerSize.height - height, width: finalWidth, height: height).inset(by: cardEdgeInsets)
        }
    }

    public func hideDimmingOverlay(_ hidden: Bool) {
        UIView.animate(withDuration: 0.3) { [dimmingView] in
            dimmingView.alpha = hidden ? 0 : 1
        }
    }

    @objc private func didTapDimmingView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
