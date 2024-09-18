//
//  BadgeView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 15.08.24.
//

import UIKit

public final class BadgeView: UIView {

    private let textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .backgroundAccentSubtle

        layer.borderWidth = 1
        layer.borderColor = UIColor.borderAccentSubtle.cgColor
        layer.masksToBounds = true
        apply(cornerRadius: 12)
        self.addSubview(textLabel)
        textLabel.pinTop(to: self, insets: UIEdgeInsets(horizontal: .spacing.xs, vertical: .spacing.xxs))
        heightAnchor.constraint(equalToConstant: .h24).isActive = true
    }

    public func configure(text: String) {
        self.textLabel.attributedText = .attributedString(with: text, style: .h6, decorations: [.color(.textAccent)])
    }
}
