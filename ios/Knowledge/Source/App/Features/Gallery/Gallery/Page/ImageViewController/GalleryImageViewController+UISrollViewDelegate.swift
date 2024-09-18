//
//  GalleryImageViewController+UISrollViewDelegate.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import UIKit

extension GalleryImageViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This is the recognizer which is responsible for adjusting the panels size ...
        guard let recognizer = panel?.view.gestureRecognizers?.compactMap({
            $0 as? Aiolos.NoDelayPanGestureRecognizer
        }).first else { return }

        // Cancel panel resizing in case we're scrolling the scrollview, but:
        // collapse the panel in case we're dragging beyond the scrollviews upper content edge ...
        if scrollView.isTracking, recognizer.state == .began || recognizer.state == .changed, scrollView.contentOffset.y > 0 {
            recognizer.isEnabled = false
            recognizer.isEnabled = true
        }
    }
}
