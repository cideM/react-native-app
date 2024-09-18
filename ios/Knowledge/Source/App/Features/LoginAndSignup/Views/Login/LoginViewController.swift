//
//  LoginViewController.swift
//  LoginAndSignup
//
//  Created by CSH on 31.01.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol LoginViewType: AnyObject {
    func setIsLoading(_ isLoading: Bool)
    func setLoginButtonIsEnabled(_ isEnabled: Bool)
    func prefill(email: String?, password: String?)
    func presentMessage(_ message: PresentableMessageType)
}

final class LoginViewController: UIViewController, LoginViewType {
    @IBOutlet private var emailTextField: BigTextField!
    @IBOutlet private var passwordTextField: BigTextField!
    @IBOutlet private var loginButton: BigButton! {
        didSet {
            loginButton.isEnabled = false
        }
    }
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var forgotPasswordButton: BigButton!
    @IBOutlet private var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private var ssoHintImageView: UIImageView! {
        didSet {
            ssoHintImageView.tintColor = ThemeManager.currentTheme.tintColor
            ssoHintImageView.image = Asset.Icon.infoIcon.image
        }
    }
    @IBOutlet private var ssoHintTextView: UITextView! {
        didSet {
            ssoHintTextView.delegate = self
            ssoHintTextView.textContainerInset = .zero
            ssoHintTextView.textContainer.lineFragmentPadding = 0
        }
    }

    private let presenter: LoginPresenterType
    private var timer: Timer?
    private var keyboardConstraintUpdater: KeyboardConstraintUpdater?

    init(presenter: LoginPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle(for: LoginViewController.self))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self

        view.backgroundColor = .backgroundPrimary
        view.preservesSuperviewLayoutMargins = true

        loginButton.style = .primary
        forgotPasswordButton.style = .link

        title = L10n.Login.title

        loginButton.setTitle(L10n.Login.title.uppercased(), for: .normal)
        forgotPasswordButton.setTitle(L10n.Login.forgotPasswordButtonTitle, for: .normal)
        forgotPasswordButton.sizeToFit()
        emailTextField.placeholder = L10n.Login.emailPlaceholder
        passwordTextField.placeholder = L10n.Login.passwordPlaceholder

        emailTextField.rightButtonTappedClosure = presenter.didTapClearButton
        passwordTextField.rightButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.presenter.didTapPasswordToggleButton(isvisible: self.passwordTextField.isSecureTextEntry)
        }

        let ssoHintText = NSMutableAttributedString(string: L10n.Login.SsoHint.firstLine + "\n" + L10n.Login.SsoHint.secondLine,
                                                    attributes: ThemeManager.currentTheme.loginSSOHintTextAttributes)
        let secondLineLinkRange = ssoHintText.mutableString.range(of: L10n.Login.SsoHint.secondLine)
        ssoHintText.addAttributes([.link: presenter.forgotPasswordUrl], range: secondLineLinkRange)
        ssoHintTextView.attributedText = ssoHintText
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardConstraintUpdater?.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardConstraintUpdater?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            loginButton.isEnabled = false
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            loginButton.isEnabled = true
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    func setLoginButtonIsEnabled(_ isEnabled: Bool) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.loginButton.isEnabled = isEnabled
        }
    }

    func prefill(email: String?, password: String?) {
        emailTextField.text = email
        passwordTextField.text = password
    }

    func presentMessage(_ message: PresentableMessageType) {
        let messagePresenter = UIAlertMessagePresenter(presentingViewController: self)
        messagePresenter.present(message, actions: [.dismiss])
    }

    private func hideKeyboard() {
        view.endEditing(true)
    }

    private func performLoginCall() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        hideKeyboard()
        presenter.didTapLoginButton(email: email, password: password)
    }
}

extension LoginViewController {
    @IBAction private func loginButtonTapped(_ sender: AnyObject) {
        performLoginCall()
    }

    @IBAction private func textFieldDidChange(_ sender: UITextField) {
        presenter.validateCredentials(email: emailTextField.text, password: passwordTextField.text)
    }

    @IBAction private func forgotPasswordButtonTapped(_ sender: UIButton) {
        presenter.didTapForgotPasswordButton()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        hideKeyboard()
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            performLoginCall()
        }
        return false
    }
}

extension LoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL == presenter.forgotPasswordUrl {
            presenter.didTapForgotPasswordButton()
        }

        return false
    }
}
