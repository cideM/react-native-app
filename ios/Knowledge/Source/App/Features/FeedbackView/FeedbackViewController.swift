//
//  FeedbackViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 19.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization
import DesignSystem

/// @mockable
protocol FeedbackViewType: AnyObject {
    func showIntentionsMenu(with intentions: [FeedbackIntention])
    func setSelectedIntention(_ intention: FeedbackIntention)
    func setSubmitFeedbackButtonIsEnabled(_ isEnabled: Bool)
    func showMessageTextView()
}

final class FeedbackViewController: UIViewController, FeedbackViewType {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .attributedString(with: L10n.Feedback.Header.title, style: .h2, decorations: [.color(.textSecondary)])

        return label
    }()

    private lazy var intentionTextField: BigTextField = {
        let textField = BigTextField()
        textField.attributedPlaceholder = .attributedString(with: L10n.Feedback.Intention.placeholder, style: .paragraphSmallBold, decorations: [.color(.textTertiary)])
        textField.delegate = self

        let chevronImageView = UIImageView(image: Asset.Icon.disclosureArrow.image)
        chevronImageView.tintColor = .iconTertiary
        textField.rightView = chevronImageView

        return textField
    }()

    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.borderPrimary.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.typingAttributes = .attributes(style: .paragraphSmallBold, with: [.color(.textSecondary)])
        textView.alpha = 0.0
        textView.isHidden = true
        textView.delegate = self
        return textView
    }()

    private lazy var sendButton: BigButton = {
        let button = BigButton()
        button.style = .primary
        button.setTitle(L10n.Feedback.SendFeedbackButton.title, for: [])
        button.touchUpInsideActionClosure = { [weak self] in
            guard let self = self else { return }
            self.presenter.submitFeedback()
        }
        button.isEnabled = false
        return button
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()

    private let presenter: FeedbackPresenterType
    private var keyboardConstraintUpdater: KeyboardConstraintUpdater?

    init(presenter: FeedbackPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Feedback.title
        view.backgroundColor = .canvas

        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(intentionTextField)
        mainStackView.addArrangedSubview(messageTextView)
        mainStackView.addArrangedSubview(sendButton)

        view.addSubview(mainStackView)

        setupConstraints()

        presenter.view = self
    }

    func showIntentionsMenu(with intentions: [FeedbackIntention]) {
        let intentionsActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        intentions
            .map { intention in
                UIAlertAction(title: intention.description, style: .default) { [weak self] _ in
                    self?.presenter.selectedIntention = intention
                }
            }
            .forEach { action in
                intentionsActionSheet.addAction(action)
            }

        intentionsActionSheet.addAction(UIAlertAction(title: L10n.Feedback.IntentionsMenu.cancelButton, style: .cancel))

        intentionsActionSheet.popoverPresentationController?.sourceView = intentionTextField
        intentionsActionSheet.view.tintColor = .textPrimary

        present(intentionsActionSheet, animated: true)
    }

    func setSelectedIntention(_ intention: FeedbackIntention) {
        intentionTextField.text = intention.description
    }

    func setSubmitFeedbackButtonIsEnabled(_ isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }

    func showMessageTextView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            self.messageTextView.alpha = 1.0
            self.messageTextView.isHidden = false
        } completion: { _ in
            self.messageTextView.becomeFirstResponder()
        }
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

        intentionTextField.translatesAutoresizingMaskIntoConstraints = false
        intentionTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
        ])

        let bottomConstraint = mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint.isActive = true
        bottomConstraint.priority = .defaultLow
        keyboardConstraintUpdater = KeyboardConstraintUpdater(rootView: view, constraints: [bottomConstraint])
    }
}

extension FeedbackViewController: UITextFieldDelegate {
    // unused:ignore textFieldShouldBeginEditing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        presenter.selectIntentionTapped()
        return false
    }
}

extension FeedbackViewController: UITextViewDelegate {
    // unused:ignore textViewDidChange
    func textViewDidChange(_ textView: UITextView) {
        presenter.feedbackText = textView.text
    }
}
