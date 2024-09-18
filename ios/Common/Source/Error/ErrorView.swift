//
//  ErrorView.swift
//  Knowledge
//
//  Created by Silvio Bulla on 26.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit
import DesignSystem

final class ErrorView: UIView {

    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private let meassagelabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .textTertiary
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .textSecondary
        label.font = UIFont.boldSystemFont(ofSize: 28)
        return label
    }()

    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let actions: [MessageAction]
    private let message: String
    private let title: String?
    private let image: UIImage?

    private var headerImage: UIImage {
        image ?? Common.Asset.errorImage.image
    }

    init(actions: [MessageAction], message: PresentableMessageType) {
        self.actions = actions
        self.title = message.title
        self.message = message.body
        self.image = message.image
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ErrorView {
    func setupView() {
        backgroundColor = .backgroundPrimary
        headerImageView.image = headerImage
        meassagelabel.text = message
        titleLabel.text = title

        rootStackView.addArrangedSubview(headerImageView)
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(meassagelabel)

        headerImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        meassagelabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        for action in actions {
            actionsStackView.addArrangedSubview(createButton(with: action))
        }

        addSubview(rootStackView)
        addSubview(actionsStackView)

        setupConstraints()
    }

    func createButton(with action: MessageAction) -> UIButton {
        let button = BigButton(type: .system)
        // Remove ErrorView from superview if the error is fully handled.
        button.touchUpInsideActionClosure = { [weak self] in
            if action.execute() {
                self?.removeFromSuperview()
            }
        }
        button.setTitle(action.title.uppercased(), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.adjustsImageWhenHighlighted = true

        switch action.style {
        case .primary: button.style = .primary
        case .normal: button.style = .normal
        case .link: button.style = .link
        }

        return button
    }

    func setupConstraints() {
        if actions.isEmpty {
            rootStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
        } else {
            rootStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        }
        rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true

        actionsStackView.topAnchor.constraint(greaterThanOrEqualTo: rootStackView.bottomAnchor).isActive = true
        actionsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        actionsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        actionsStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }
}
