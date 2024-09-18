//
//  ActivityIndicator.swift
//  Common
//
//  Created by Maksim Tuzhilin on 06.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

public class ActivityIndicatorView: UIView {
    private var animationDuration: TimeInterval {
        if UIAccessibility.isReduceMotionEnabled {
            return 0.0
        }
        return 0.2
    }

    private var overlayAlpha: CGFloat {
        if UIAccessibility.isReduceTransparencyEnabled {
            return 1.0
        }
        return 0.8
    }

    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

    private lazy var overlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .backgroundPrimary
        return overlay
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public func didMoveToSuperview() {
        guard let superview = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        constrainEdges(to: superview)
    }

    public func show() {
        isHidden = false
        self.overlay.alpha = 0.0
        activityIndicator.alpha = 0.0
        activityIndicator.startAnimating()

        UIView.animate(withDuration: animationDuration) {
            self.overlay.alpha = self.overlayAlpha
            self.activityIndicator.alpha = 1.0
        }
    }

    public func hide() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.overlay.alpha = 0
            self.activityIndicator.alpha = 0
        }, completion: { _ in
            self.activityIndicator.stopAnimating()
            self.isHidden = true
        })
    }

    private func commonInit() {
        isHidden = true

        setupOverlay()
        setupActivityIndicator()
    }

    private func setupOverlay() {
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        overlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
