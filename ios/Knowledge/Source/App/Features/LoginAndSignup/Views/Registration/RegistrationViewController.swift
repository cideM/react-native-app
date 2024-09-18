//
//  RegisterViewController.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 12.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
public protocol RegistrationViewType: AnyObject {
    func setIsLoading(_ isLoading: Bool)
    func showEmailInformationLabel(text: String)
    func setButtonTitle(text: String)
    func presentMessage(_ message: PresentableMessageType)
}

public final class RegistrationViewController: UIViewController, RegistrationViewType {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelCreateYourAccountText, attributes: ThemeManager.currentTheme.signUpTitleLabelTextAttributes)
        }
    }
    @IBOutlet private weak var emailTextField: BigTextField! {
        didSet {
            emailTextField.placeholder = L10n.SignUp.textFieldEmailPlaceholder
            emailTextField.rightButtonTappedClosure = { [weak self] in
                guard let self = self else { return }
                self.presenter.emailTextFieldRightButtonTapped()
            }
        }
    }
    @IBOutlet private weak var emailInformationLabel: UILabel! {
        didSet {
            emailInformationLabel.isHidden = true
            emailInformationLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelEmailInformationText, attributes: ThemeManager.currentTheme.informationLabelTextAttributesRed)
        }
    }
    @IBOutlet private weak var passwordTextField: BigTextField! {
        didSet {
            passwordTextField.placeholder = L10n.SignUp.textFieldPasswordPlaceholder
            passwordTextField.rightButtonTappedClosure = { [weak self] in
                guard let self = self else { return }
                self.presenter.passwordTextFieldRightButtonTapped(isVisible: self.passwordTextField.isSecureTextEntry)
            }
        }
    }
    @IBOutlet private weak var passwordInformationLabel: UILabel! {
        didSet {
            passwordInformationLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelPasswordInformationText, attributes: ThemeManager.currentTheme.informationLabelTextAttributes)
        }
    }
    @IBOutlet private weak var startButton: BigButton! {
        didSet {
            startButton.style = .primary
            startButton.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: startButton.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
        }
    }
    @IBOutlet private weak var loginLabel: UILabel! {
        didSet {
            loginLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelAlreadyRegisteredText, attributes: ThemeManager.currentTheme.signUpAlreadyRegisteredLabelTextAttributes)
            loginLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapFunction)))
        }
    }
    private var presenter: RegistrationPresenterType
    private var timer: Timer?
    static let emailRegexString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    init(presenter: RegistrationPresenterType) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: Bundle(for: LoginViewController.self))
        title = L10n.SignUp.title
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        view.backgroundColor = .backgroundPrimary

        stackView.setCustomSpacing(10, after: titleLabel)
        stackView.setCustomSpacing(6, after: passwordTextField)
        stackView.setCustomSpacing(40, after: passwordInformationLabel)
        stackView.setCustomSpacing(24, after: startButton)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    public func setButtonTitle(text: String) {
        startButton.setTitle(text, for: .normal)
    }

    private func hideEmailInformationLabel() {
        emailInformationLabel.isHidden = true
        stackView.setCustomSpacing(16, after: emailTextField)
    }

    public func showEmailInformationLabel(text: String) {
        emailInformationLabel.isHidden = false
        stackView.setCustomSpacing(6, after: emailTextField)
        emailInformationLabel.attributedText = NSAttributedString(string: text, attributes: ThemeManager.currentTheme.informationLabelTextAttributesRed)
    }

    public func presentMessage(_ message: PresentableMessageType) {
        let messagePresenter = UIAlertMessagePresenter(presentingViewController: self)
        messagePresenter.present(message, actions: [.dismiss])
    }

    private func setErrorMessages() {
        if isValidEmail(emailTextField.text ?? "") {
            hideEmailInformationLabel()
        } else {
            showEmailInformationLabel(text: L10n.SignUp.labelInvalidEmailAdressText)
        }

        if isValidPassword(passwordTextField.text ?? "") {
            passwordInformationLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelPasswordInformationText, attributes: ThemeManager.currentTheme.informationLabelTextAttributes)
        } else {
            passwordInformationLabel.attributedText = NSAttributedString(string: L10n.SignUp.labelPasswordInformationText, attributes: ThemeManager.currentTheme.informationLabelTextAttributesRed)
        }
    }

    @IBAction private func startButtonTouchUpInside() {
        setErrorMessages()
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        if isValidEmail(email) && isValidPassword(password) {
            self.setIsLoading(true)
            presenter.startButtonTapped(with: email, password: password)
        }
    }

    @objc
    private func tapFunction(sender: UITapGestureRecognizer) {
        presenter.navigateToLogin(email: emailTextField.text, password: passwordTextField.text)
    }

    private func isValidEmail(_ text: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegistrationViewController.emailRegexString)
        guard predicate.evaluate(with: text) else { return false }
        return true
    }

    private func isValidPassword(_ string: String) -> Bool {
        let minimumPasswordLength = 8
        return string.count >= minimumPasswordLength
    }

    public func setIsLoading(_ isLoading: Bool) {
        startButton.isEnabled = !isLoading
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
}

extension RegistrationViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            startButtonTouchUpInside()
        }
        return false
    }
}
