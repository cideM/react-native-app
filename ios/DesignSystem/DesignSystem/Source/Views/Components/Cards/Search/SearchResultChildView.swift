//
//  SearchResultChildView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 04.04.24.
//

import UIKit

public final class SearchResultChildView: UIView {

    public struct ViewData {
        let title: NSAttributedString?
        let body: NSAttributedString?
        let level: Int

        public init(title: NSAttributedString?,
                    body: NSAttributedString?,
                    level: Int) {
            self.title = title
            self.body = body
            self.level = level
        }
    }

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    let separator: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .dividerPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var leadingConstraint: NSLayoutConstraint?

    override public init(frame: CGRect = .zero) {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .backgroundSecondary
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .clear
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .clear
    }

    private func commonInit() {
        backgroundColor = .clear
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)
        addSubview(stackView)
        addSubview(separator)

        let (_, _, leading, _) = stackView.pin(to: self,
                                               insets: UIEdgeInsets(horizontal: .spacing.m,
                                                                    vertical: .spacing.s))
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.leadingConstraint = leading
    }

    public func configure(viewData: ViewData, hideSeparator: Bool) {
        titleLabel.attributedText = viewData.title
        bodyLabel.attributedText = viewData.body
        bodyLabel.isHidden = viewData.body?.string.isEmpty ?? true
        leadingConstraint?.constant = .spacing.m * CGFloat(viewData.level)
        separator.isHidden = hideSeparator
    }
}
