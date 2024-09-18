//
//  LoginView.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 14.12.23.
//

import UIKit
import DesignSystem

public protocol LoginViewDelegate_Experimental: AnyObject {
    func didTapRegistrationButton()
}

public class LoginViewDemo_Experimental: UIView {

    public weak var delegate: LoginViewDelegate_Experimental?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        compose()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var imageView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.Experimental.loginBackground.image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.Experimental.logo.image
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var logoImageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var loginButton: PrimaryButton_Experimental = {
        var view = PrimaryButton_Experimental()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.title = "Login"
        return view
    }()

    private var registerButton: PrimaryButton_Experimental = {
        var view = PrimaryButton_Experimental()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.title = "Sign Up"
        return view
    }()

    private var buttonStackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = .spacing.xs
        return view
    }()

    private var buttonStackViewContainer: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var contentStackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = .spacing.xs
        return view
    }()

    private var contentStackViewContainer: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {
        var view = UILabel()
        view.numberOfLines = 0
        let text = "Medizinwissen, auf das man sich verlassen kann"
        view.attributedText = .attributedString(with: text, style: .h2, decorations: [.color(.textOnAccent)])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var describtionLabel: UILabel = {
        var view = UILabel()
        view.numberOfLines = 0
        let text = "denn Wissen ist Grundlage jeder ärztlichen Entscheidung"
        view.attributedText = .attributedString(with: text, style: .paragraphSmallBold, decorations: [.color(.textOnAccent)])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var mainStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    // MARK: - Private
    private func compose() {

        addSubview(imageView)
        imageView.pin(to: self)

        addBlur()

        addSubview(mainStackView)
        mainStackView.pin(to: safeAreaLayoutGuide)

        logoImageViewContainer.addSubview(logoImageView)
        logoImageView.pinLeft(to: logoImageViewContainer, insets: .init(top: 60.0, left: .spacing.l, bottom: 0.0, right: -.spacing.l))
        mainStackView.addArrangedSubview(logoImageViewContainer)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(describtionLabel)
        contentStackViewContainer.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentStackViewContainer.topAnchor, constant: 150),
            contentStackView.leadingAnchor.constraint(equalTo: contentStackViewContainer.leadingAnchor, constant: .spacing.l),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentStackViewContainer.bottomAnchor),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentStackViewContainer.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalToConstant: 270.0)
        ])

        mainStackView.addArrangedSubview(contentStackViewContainer)

        buttonStackView.addArrangedSubview(loginButton)
        buttonStackView.addArrangedSubview(registerButton)
        buttonStackViewContainer.addSubview(buttonStackView)
        buttonStackView.pin(to: buttonStackViewContainer,
                            insets: .init(top: .spacing.l,
                                          left: .spacing.l,
                                          bottom: .spacing.xl,
                                          right: .spacing.l))

        mainStackView.addArrangedSubview(buttonStackViewContainer)

        registerButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc func didTap() {
        delegate?.didTapRegistrationButton()
    }

    override public func setNeedsLayout() {
        super.setNeedsLayout()
        gradientMaskLayer.frame = bounds
    }

    private var gradientMaskLayer = CAGradientLayer()
    private func addBlur() {

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false

        gradientMaskLayer.frame = bounds
        let c1 = UIColor.clear.cgColor
        let c2 = UIColor.white.withAlphaComponent(1.0).cgColor
        gradientMaskLayer.colors = [c1, c2]
        gradientMaskLayer.locations = [0.3, 1]
        blurView.layer.mask = gradientMaskLayer

        addSubview(blurView)
        blurView.pin(to: self)
    }

}
