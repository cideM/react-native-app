//
//  LearningCardToolbar.Seperator.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 12.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

extension LearningCardToolbar {

    /// This is  a standard UIControl subclass with these specifics:
    /// * It's supposed to be used inside control groups of LearningCardToolbar
    /// * It simply displays a vertical line and is supposed to be used to visually seperate elements
    /// * It's not supposed to perform any action when tapped (although its possible to add one to it)
    class Separator: UIControl {

        // MARK: - Init

        @available(*, unavailable)
        override init(frame: CGRect) {
            fatalError("init(frame: CGRect) has not been implemented")
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        required init(width: CGFloat) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false

            let line = UIView(frame: .zero)
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = ThemeManager.currentTheme.defaultShadowColor

            addSubview(line)
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: width),
                line.widthAnchor.constraint(equalToConstant: 1),
                line.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                line.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }
    }
}
