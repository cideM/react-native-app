//
//  PanGestureInteractionController.swift
//  Common
//
//  Created by Azadeh Richter on 30.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

class PanGestureInteractionController: UIPercentDrivenInteractiveTransition {

    // MARK: - Variables
    var didBeginPanningHandler: (() -> Void)?

    private let percentCompletedThreshold: CGFloat = 0.3
    private let gestureRecognizer: UIPanGestureRecognizer
    private let edge: SlideInTransitionEdge

    // MARK: - Object lifecycle

    init(view: UIView, edge: SlideInTransitionEdge) {
        self.edge = edge
        self.gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)

        super.init()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(panHandler(_:)))
    }

    // MARK: - Pan Handler

    @objc
    private func panHandler(_ sender: UIPanGestureRecognizer) {
        let percentCompleted = self.percentCompleted(panGestureRecognizer: sender)

        switch sender.state {
        case .began:
            didBeginPanningHandler?()
        case .changed:
            update(percentCompleted)
        case .ended:
            let velocityInPecent = self.velocityInPercent(panGestureRecognizer: sender)
            (percentCompleted + 0.1 * velocityInPecent) > percentCompletedThreshold ? finish() : cancel()
        case .cancelled:
            cancel()
        default:
            return
        }
    }

    private func percentCompleted(panGestureRecognizer sender: UIPanGestureRecognizer) -> CGFloat {
        guard let view = sender.view else {
            return 0
        }
        let translation = sender.translation(in: view)
        let panVector = edge.panVector(forView: view)

        switch (panVector.x, panVector.y) {
        case (0, 0): return 0
        case (0, _): return translation.y / panVector.y
        case (_, 0): return translation.x / panVector.x
        case (_, _): return max(translation.y / panVector.y, translation.x / panVector.x)
        }
    }

    private func velocityInPercent(panGestureRecognizer sender: UIPanGestureRecognizer) -> CGFloat {
        guard let view = sender.view else {
            return 0
        }
        let velocity = sender.velocity(in: view)
        let panVector = edge.panVector(forView: view)

        switch (panVector.x, panVector.y) {
        case (0, 0): return 0
        case (0, _): return velocity.y / panVector.y
        case (_, 0): return velocity.x / panVector.x
        case (_, _): return max(velocity.y / panVector.y, velocity.x / panVector.x)
        }
    }

}

private extension SlideInTransitionEdge {
    func panVector(forView view: UIView) -> CGPoint {
        switch self {
        case .left: return CGPoint(x: -view.bounds.size.width, y: 0)
        case .right: return CGPoint(x: view.bounds.size.width, y: 0)
        case .top: return CGPoint(x: 0, y: -view.bounds.size.height)
        case .bottom: return CGPoint(x: 0, y: view.bounds.size.height)
        }
    }
}

extension PanGestureInteractionController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.gestureRecognizer else { assertionFailure("I should not be the delegate for that UIGestureRecognizer"); return true }

        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
              let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        if let scrollView = otherPanGestureRecognizer.view as? UIScrollView {
            if ![.failed, .ended, .cancelled].contains(self.gestureRecognizer.state) {
                if edge == .bottom && panGestureRecognizer.direction == .bottom && scrollView.isAtTop ||
                    edge == .top && panGestureRecognizer.direction == .top && scrollView.isAtBottom ||
                    edge == .left && panGestureRecognizer.direction == .left && scrollView.isAtLeft ||
                    edge == .right && panGestureRecognizer.direction == .right && scrollView.isAtRight {
                    // As soon as, we set the 'isEnabled' property of the `panGesture` to false,
                    // panGesture will be cancelled on the scrollView.
                    // We set that back to true immediately for the next coming gestures.
                    scrollView.panGestureRecognizer.isEnabled = false
                    scrollView.panGestureRecognizer.isEnabled = true
                } else {
                    // Inside a snippet view we need to skip gestures and scroll content
                    return false
                }
            }
        }

        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.gestureRecognizer else { assertionFailure("I should not be the delegate for that UIGestureRecognizer"); return true }

        let velocity = self.gestureRecognizer.velocity(in: self.gestureRecognizer.view)
        let isVerticalDirection = abs(velocity.y) > abs(velocity.x)

        return isVerticalDirection == [.top, .bottom].contains(edge)
    }
}

private extension UIPanGestureRecognizer {

    var direction: SlideInTransitionEdge? {
        guard let view = view else {
            return nil
        }

        let translation = self.velocity(in: view)

        if abs(translation.y) > abs(translation.x) {
            return translation.y > 0.0 ? .bottom : .top
        } else if abs(translation.y) < abs(translation.x) {
            return translation.x > 0.0 ? .right : .left
        } else {
            return nil
        }
    }
}
