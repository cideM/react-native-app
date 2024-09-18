//
//  LearningCardToolbar.Button.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 12.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

extension LearningCardToolbar {

    /// This is  a standard UIControl (button kind) subclass with these specifics:
    /// * It's supposed to be used inside control groups of LearningCardToolbar
    /// * It shows an icon on top and a title below the icon
    class Button: UIControl {

        override var isHighlighted: Bool { didSet { update(with: state) } }
        override var isSelected: Bool { didSet { update(with: state) } }
        override var isEnabled: Bool { didSet { update(with: state) } }

        private let label: UILabel = {
            let label = UILabel(frame: .zero)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = Font.regular.font(withSize: 10)
            return label
        }()

        private let image: UIImageView = {
            let view = UIImageView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .center
            return view
        }()

        private var colors = [UInt: UIColor]()
        private var handler: (() -> Void)?

        // MARK: - Init

        @available(*, unavailable)
        override init(frame: CGRect) {
            fatalError("init(frame: CGRect) has not been implemented")
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        init(title: String = "", image: UIImage, handler: @escaping () -> Void) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false

            label.text = title
            self.image.image = image

            addSubview(label)
            NSLayoutConstraint.activate([
                bottomAnchor.constraint(equalTo: label.bottomAnchor),
                leadingAnchor.constraint(equalTo: label.leadingAnchor),
                trailingAnchor.constraint(equalTo: label.trailingAnchor),
                label.heightAnchor.constraint(equalToConstant: 14)
            ])

            addSubview(self.image)
            NSLayoutConstraint.activate([
                self.image.topAnchor.constraint(equalTo: topAnchor),
                self.image.bottomAnchor.constraint(equalTo: label.topAnchor),
                leadingAnchor.constraint(equalTo: self.image.leadingAnchor),
                trailingAnchor.constraint(equalTo: self.image.trailingAnchor)
            ])

            self.handler = handler
            addTarget(self, action: #selector(executeHandler(_:)), for: .touchUpInside)
        }

        // MARK: - Setters

        func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
            colors[state.rawValue] = color
            update(with: self.state)
        }

        func setTitle(_ title: String) {
            label.text = title
        }

        func setImage(_ image: UIImage) {
            self.image.image = image
        }
    }
}

private extension LearningCardToolbar.Button {

    @objc func executeHandler(_ sender: AnyObject) {
        handler?()
    }

    func update(with state: UIControl.State) {
        guard let color = colors[state.rawValue] else { return }
        image.tintColor = color
        label.textColor = color
    }
}
