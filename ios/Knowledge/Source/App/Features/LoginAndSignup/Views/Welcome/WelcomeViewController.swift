//
//  WelcomeViewController.swift
//  LoginAndSignup
//
//  Created by CSH on 31.01.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization
import DesignSystem

protocol WelcomeViewType: AnyObject {}

internal final class WelcomeViewController: UIViewController, WelcomeViewType {

    private let darkenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundBackdrop
        return view
    }()

    @IBOutlet private var headerImageView: UIImageView! {
        didSet {
            headerImageView.image = Common.Asset.logoAndNameHorizontalWhite.image
        }
    }
    @IBOutlet private weak var backgroundImageView: UIImageView?
    @IBOutlet private weak var gradientImageView: UIImageView?
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var signUpButton: BigButton!
    @IBOutlet private var loginButton: SecondaryButton!
    @IBOutlet private weak var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageTopConstraint: NSLayoutConstraint!

    private let localizations: L10n.Welcome.Type
    private let backgroundImage: UIImage
    private let gradientImage: UIImage
    private let presenter: WelcomePresenterType

    init(presenter: WelcomePresenterType, localizations: L10n.Welcome.Type, backgroundImage: UIImage, gradientImage: UIImage) {
        self.presenter = presenter
        self.localizations = localizations
        self.backgroundImage = backgroundImage
        self.gradientImage = gradientImage

        super.init(nibName: "WelcomeViewController", bundle: Bundle(for: WelcomeViewController.self))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        configure()
        registerObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func registerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Self.orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc private func orientationDidChange() {

        // Listening on the `UIDevice.orientationDidChangeNotification` and calling the `orientationDidChange()`
        // fixes the problem that the layout was broken on the iPad after rotation. The previous implementation
        // was making use of size classes. Roberto figured out the the previous version was not working any more
        // due to Xcode changes beginning of V13. We go with the naive and easy approach of acting on device rotation
        // when we are on the iPad.
        if UIDevice.current.userInterfaceIdiom == .pad {
            loginButtonBottomConstraint.constant = UIDevice.current.orientation.isPortrait ? 251 : 59
            headerImageTopConstraint.constant = UIDevice.current.orientation.isPortrait ? 228 : 62
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkenView.isHidden = traitCollection.userInterfaceStyle == .light
    }
}

private extension WelcomeViewController {
    @IBAction private func signupButtonTapped(_ sender: Any) {
        presenter.signupButtonTapped()
    }

    @IBAction private func loginButtonTapped(_ sender: Any) {
        presenter.loginButtonTapped()
    }

    func configure() {

        backgroundImageView?.image = backgroundImage
        gradientImageView?.image = gradientImage

        if let bgView = backgroundImageView {
            bgView.addSubview(darkenView)
            darkenView.pin(to: bgView)
        }
        darkenView.isHidden = traitCollection.userInterfaceStyle == .light

        view.backgroundColor = ThemeManager.currentTheme.tintColor

        if let backgroundImageView = backgroundImageView, backgroundImage.size.width != 0 {
            backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor, multiplier: backgroundImage.size.height / backgroundImage.size.width).isActive = true
        }

        signUpButton?.style = .welcome

        signUpButton?.setTitle(localizations.signUpButtonTitle.uppercased(), for: .normal)
        loginButton?.title = L10n.Login.title.uppercased()

        titleLabel.attributedText = NSAttributedString(string: localizations.title, attributes: ThemeManager.currentTheme.welcomeViewTitleTextAttributes)
        subtitleLabel.attributedText = NSAttributedString(string: localizations.subtitle, attributes: ThemeManager.currentTheme.welcomeViewSubtitleTextAttributes)
    }
}
