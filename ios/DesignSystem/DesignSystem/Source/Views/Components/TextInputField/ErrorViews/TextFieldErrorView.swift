//
//  TextFieldErrorView.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 29.11.23.
//

import UIKit

public class TextFieldErrorView: UIView {

    public var title: String? = "" {
        didSet {
            titleLabel.attributedText = .attributedString(with: title ?? "",
                                                          style: .paragraphSmall,
                                                          decorations: [.color(.textError)])
        }
    }

    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        compose()
    }

    // MARK: - Composition
    private func compose() {
        addSubview(stackView)
        stackView.pin(to: self, insets: .init(top: 0.0, left: .spacing.xxxs, bottom: 0.0, right: 0.0))
        stackView.addArrangedSubview(iconImageView)

        labelContainerView.addSubview(titleLabel)
        titleLabel.pinLeft(to: labelContainerView)
        stackView.addArrangedSubview(labelContainerView)
    }

    // MARK: - Private
    private let labelContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let image = Asset.Icon.info.image
        view.tintColor = .iconError
        view.contentMode = .center
        view.image = image
        return view
    }()

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = .spacing.xxs
        return stackView
    }()
}
