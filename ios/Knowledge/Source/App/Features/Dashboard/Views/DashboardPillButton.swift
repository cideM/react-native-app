//
//  DashboardPillButton.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 19.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

/// Reasons for existence of this subclass:
/// * Display a pill shaped button
class DashboardPillButton: UIButton {

    private var heightConstraint: NSLayoutConstraint?

    override var bounds: CGRect {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = bounds.height / 2.0
        }
    }
}
