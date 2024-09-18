//
//  GalleryImageViewController+PanelDelegates.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import Common
import simd
import UIKit

// MARK: - PanelSizeDelegate

extension GalleryImageViewController: PanelSizeDelegate {

    func panel(_ panel: Panel, sizeForMode mode: Panel.Configuration.Mode) -> CGSize {
        switch mode {
        case .minimal: // -> "minimal" is not used
            return .zero
        case .compact:
            return CGSize(width: view.bounds.width, height: panelMinHeight())
        case .expanded:
            // The panel "snaps" to the expanded height once its dragged up there
            // We always want this to be the middle of the screen
            // or lower, but NOT higher. So the user can learn the gesture:
            // -> Swipe till middle always "snaps" the card open
            return CGSize(width: view.bounds.width, height: panelExpandedHeight())
        case .fullHeight:
            return CGSize(width: view.bounds.width, height: 0)
        }
    }
}

// MARK: - PanelResizeDelegate

extension GalleryImageViewController: PanelResizeDelegate {

    func panelDidStartResizing(_ panel: Panel) {
        // WORKAROUND:
        // Temporary disabel the iOS modals "drag to dismiss" gesture
        // when the user is dragging the panel ...
        presentationControllerDismissalRecognizer?.isEnabled = false
        presentationControllerDismissalRecognizer?.isEnabled = true
    }

    func panel(_ panel: Panel, willResizeTo size: CGSize) {
        presenter.updateDraggingState(isDragging: true)

        // Keep the image centered in the remaining visible space
        // This is wrapped in an animation block to avoid jumps when the panel "snaps" into place
        self.imageViewBottomAnchorConstraint?.constant = size.height
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }

        // Only do this if we actually have content that needs fading out
        // Otherwise the copyright notice might just disappear
        // (Its sometimes the only thing and hence panel sizing is disabled)
        if !wasContentInitiallyCompletelyVisible {
            // Smoothstep between "collapsed" and "expanded" background color
            let edge0 = SIMD2<Float>(repeating: Float(panelMinHeight()))
            let edge1 = SIMD2<Float>(repeating: Float(panelExpandedHeight()))
            let posx = SIMD2<Float>(repeating: Float(size.height))
            let range = 1.0 - CGFloat(smoothstep(posx, edge0: edge0, edge1: edge1).y)
            contentViewController.setContentAlpha(1.0 - pow(range, 2))
            contentViewController.setChevronRotation(range: range)

            let color0: UIColor = .backgroundPrimary // <- Must be rgb for the fade to work
            let color1 = ThemeManager.currentTheme.galleryPanelCollapsedBackgroundColor
            if let transitionColor = color0.interpolateRGBColorTo(color1, fraction: range) {
                contentViewController.setBackgroundColor(transitionColor)
            }
        }

        // Enable paging only if size is close to "snapping" values ...
        let isDragging = !(size.height == panelMinHeight() || size.height == panelExpandedHeight())
        presenter.updateDraggingState(isDragging: isDragging)
    }

    func panel(_ panel: Panel, willTransitionFrom oldMode: Panel.Configuration.Mode?, to newMode: Panel.Configuration.Mode, with coordinator: PanelTransitionCoordinator) {
        coordinator.animateAlongsideTransition { [weak self] in
            guard let self = self else { return }

            switch newMode {
            case .minimal:
                break // -> "minimal" is not used
            case .compact:
                // We inset the panel a bit when collapsed cause this looks better
                // when swiping through the gallery pages ...
                panel.configuration.margins = self.collapsedPanelInsets
                panel.configuration.appearance.cornerRadius = 10
            case .expanded:
                panel.configuration.margins = self.expandedPanelInsets
                panel.configuration.appearance.cornerRadius = 16
            case .fullHeight:
                panel.configuration.margins = self.expandedPanelInsets
                panel.configuration.appearance.cornerRadius = 0
            }

            // This is also called before the view appears,
            // we only want user interactions though ...
            if self.isAnalyticsTrackingEnabled {
                switch newMode {
                case .compact: self.presenter.trackImageDescriptionDismissed()
                case .expanded: self.presenter.trackImageDescriptionPresented()
                case .minimal, .fullHeight: break
                }
            }
        }
    }
}

// Taken from here and modified:
// https://stackoverflow.com/questions/22868182/uicolor-transition-based-on-progress-value
fileprivate extension UIColor {
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        let fraction = min(max(0, fraction), 1)
        guard let color1 = self.cgColor.components, let color2 = end.cgColor.components else { return nil }
        guard color1.count == 4, color2.count == 4 else { return nil }

        let red = CGFloat(color1[0] + (color2[0] - color1[0]) * fraction)
        let green = CGFloat(color1[1] + (color2[1] - color1[1]) * fraction)
        let blue = CGFloat(color1[2] + (color2[2] - color1[2]) * fraction)
        let alpha = CGFloat(color1[3] + (color2[3] - color1[3]) * fraction)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
