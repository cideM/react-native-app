//
//  PillViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 21.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class PillViewController: UIViewController {

    private(set) lazy var scrollView: PillContainerView = {
        let view = PillContainerView(pill: toolbar)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        view.isDirectionalLockEnabled = false
        return view
    }()

    let toolbar: PillToolbarView = {
        let view = PillToolbarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = .init(origin: .zero, size: PillToolbarView.preferredSize)
        return view
    }()
}

// MARK: - Template methods

extension PillViewController {

    override func loadView() {
        view = scrollView
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
        }, completion: { _ in
            self.setPillVisibility(1.0)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setInitialPillPosition(.bottomRight)
    }
}

// MARK: Setters

extension PillViewController {

    func setPillVisibility(_ factor: CGFloat) {
        let alpha = pow(factor, 6) // -> Fade quickly
        toolbar.alpha = alpha

        let distance = 100.0
        var offsetY = distance - distance * factor
        switch scrollView.pillPosition {
        case .topLeft, .topRight: offsetY.negate()
        case .bottomLeft, .bottomRight: break
        }
        scrollView.pillOffset = .init(x: 0, y: offsetY)
    }
}
