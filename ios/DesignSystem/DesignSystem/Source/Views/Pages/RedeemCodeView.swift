//
//  RedeemCodeView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 22.12.23.
//

import UIKit
import Localization

public protocol RedeemCodeViewDelegate: AnyObject {
    func didTapRedeemButton()
    func didTapSupportButton()
    func codeDidChange(_ code: String)
}

public class RedeemCodeView: UIView {

    public let textField: LabeledWrapperView<TextInputField> = {
        let view = LabeledWrapperView<TextInputField>()
        view.title = L10n.RedeemCode.TextField.placeholder
        view.inputTextField.autocorrectionType = .no
        view.inputTextField.autocapitalizationType = .none
        view.setContentHuggingPriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let callout: CalloutView = {
        let view = CalloutView()
        view.isHidden = true
        view.setContentHuggingPriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let supportButton: TertiaryButton = {
        let view = TertiaryButton()
        view.iconType = .feedback
        view.isHidden = true
        view.title = L10n.RedeemCode.SupportButton.title
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let redeemButton: PrimaryButton = {
        let view = PrimaryButton()
        view.title = L10n.RedeemCode.Button.Title.normal
        view.iconType = .activityIndicator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = .spacing.l
        view.setContentHuggingPriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public weak var delegate: RedeemCodeViewDelegate?

    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        addSubview(stackView)

        let insets = UIEdgeInsets(top: .spacing.l,
                                        left: .spacing.m,
                                        bottom: .spacing.l,
                                        right: .spacing.m)
        textField.pinTop(to: self, insets: insets)
        stackView.pinBottom(to: self, insets: insets)
        stackView.topAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor, constant: .spacing.l).isActive = true

        stackView.addArrangedSubview(callout)
        stackView.addArrangedSubview(supportButton)
        stackView.addArrangedSubview(redeemButton)

        redeemButton.addTarget(self, action: #selector(didTapRedeem), for: .touchUpInside)
        supportButton.addTarget(self, action: #selector(didTapSupport), for: .touchUpInside)

        textField.inputTextField.delegate = self
        textField.inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
    }

    public func setCallout(viewData: CalloutView.ViewData? = nil, animated: Bool) {
        callout.viewData = viewData
        let shouldShowHelp = viewData?.calloutType == .error
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.callout.isHidden = viewData == nil
                self.supportButton.isHidden = !shouldShowHelp
                self.stackView.layoutIfNeeded()
            }
        } else {
            callout.isHidden = viewData == nil
            supportButton.isHidden = !shouldShowHelp
        }
    }

    public func setLoading(_ isLoading: Bool) {
        redeemButton.isEnabled = !isLoading
        textField.inputTextField.isEnabled = !isLoading
        redeemButton.title = isLoading ? L10n.RedeemCode.Button.Title.loading : L10n.RedeemCode.Button.Title.normal
    }

    public func setButtonTitle(_ title: String) {
        redeemButton.title = title
    }

    public func setTextFieldText(_ text: String?) {
        textField.inputTextField.text = text
    }

    @objc private func didTapSupport() {
        delegate?.didTapSupportButton()
    }

    @objc private func didTapRedeem() {
        delegate?.didTapRedeemButton()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.codeDidChange(textField.text ?? "")
    }
}

extension RedeemCodeView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didTapRedeemButton()
        return true
    }
}
