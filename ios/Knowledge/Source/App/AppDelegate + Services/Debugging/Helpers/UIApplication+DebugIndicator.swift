//
//  UIApplication+DebugIndicator.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 02.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

#if Debug || QA

extension UIApplication {

    // "Hide" and "Show" calls for senders are counted
    // All senders must have called "hide" often enough for the indicator to disappear
    // This makes sense in case several DEBUG features are turned on and off seperately during a QA session
    private static var senders = [String: Int]() {
        didSet {
            for (sender, count) in senders where count <= 0 {
                senders[sender] = nil
            }
            if senders.isEmpty {
                guard let window = UIApplication.activeKeyWindow else { return }
                window.viewWithTag(99)?.removeFromSuperview()

            } else {
                guard
                    let window = UIApplication.activeKeyWindow,
                    window.viewWithTag(99) == nil,
                    let rootViewController = window.rootViewController
                else { return }

                let indicator = ZebraView(frame: .init(origin: .zero, size: .init(width: rootViewController.view.bounds.width, height: 22)))
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.layer.zPosition = .greatestFiniteMagnitude
                indicator.tag = 99
                indicator.color = .iconBrand
                indicator.stripeColor = .tertiaryLabel

                window.addSubview(indicator)
                window.bringSubviewToFront(indicator)

                NSLayoutConstraint.activate([
                    window.leadingAnchor.constraint(equalTo: indicator.leadingAnchor),
                    window.trailingAnchor.constraint(equalTo: indicator.trailingAnchor),
                    window.topAnchor.constraint(equalTo: indicator.topAnchor),
                    window.safeTopAnchor.constraint(equalTo: indicator.bottomAnchor)
                ])

                indicator.setIsAnimating(true, animated: false)
            }
        }
    }

    static func showInddicator(tag: String) {
        senders[tag] = (senders[tag] ?? 0) + 1
    }

    static func hideInddicator(tag: String) {
        senders[tag] = (senders[tag] ?? 1) - 1

    }
}

#endif
