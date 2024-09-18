//
//  InAppPurchaseStoreViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 02.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol InAppPurchaseStoreViewType: AnyObject {
    func presentError(_ error: PresentableMessageType, _ actions: [MessageAction])
    func setLoading()
    func setReadyToBuy(localizedPrice: String,
                       offer: String?,
                       subscribeAction: @escaping () -> Void,
                       reactivateAction: @escaping () -> Void)
    func setUnlinkedInAppPurchaseSubscription(connectAction: @escaping () -> Void, cancelAction: @escaping () -> Void)
    func setActiveInAppPurchaseSubscription(buttonAction: @escaping () -> Void)
    func setActiveExternalSubscription()
    func showGenericError()
}

final class InAppPurchaseStoreViewController: UIViewController {

    private let presenter: InAppPurchaseStorePresenterType
    private let isModal: Bool
    private var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = .backgroundPrimary
        return stackView
    }()

    private var storeStaticInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 8, bottom: 20, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .backgroundPrimary
        stackView.spacing = 8
        return stackView
    }()

    private var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .backgroundPrimary
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 8
        return stackView
    }()

    private let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = .shadow
        shadowView.translatesAutoresizingMaskIntoConstraints = false

        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -1)
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.masksToBounds = false

        return shadowView
    }()

    private var shadowViewHeightConstraint: NSLayoutConstraint?

    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = UIActivityIndicatorView.Style.medium
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

    init(presenter: InAppPurchaseStorePresenterType, isModal: Bool) {
        self.presenter = presenter
        self.isModal = isModal
        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not beoverride en implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        title = L10n.Iap.Store.title
        presenter.view = self

        addTitleAndImage()

        let firstLine = createStaticInfoItemStackView(image: Asset.Icon.library.image,
                                            titleString: L10n.Iap.Paywall.Info1.title,
                                            subtitleString: L10n.Iap.Paywall.Info1.subTitle)
        storeStaticInfoStackView.addArrangedSubview(firstLine)

        let secondLine = createStaticInfoItemStackView(image: Asset.Icon.pillIcon.image,
                                             titleString: L10n.Iap.Paywall.Info2.title,
                                             subtitleString: L10n.Iap.Paywall.Info2.subTitle)

        storeStaticInfoStackView.addArrangedSubview(secondLine)

        let thirdLine = createStaticInfoItemStackView(image: Asset.Icon.wifiOff.image,
                                            titleString: L10n.Iap.Paywall.Info3.title,
                                            subtitleString: L10n.Iap.Paywall.Info3.subTitle)

        storeStaticInfoStackView.addArrangedSubview(thirdLine)

        mainStackView.addArrangedSubview(storeStaticInfoStackView)
        mainScrollView.addSubview(mainStackView)
        bottomStackView.addArrangedSubview(activityIndicatorView)
        activityIndicatorView.setAnimating(true)

        view.addSubview(mainScrollView)
        view.addSubview(shadowView)
        view.addSubview(bottomStackView)

        setupConstraints()

        if isModal {
            setModalNavigationBarStyle()
        }
    }

    private func setModalNavigationBarStyle() {
        guard let standardAppearance = navigationController?.navigationBar.standardAppearance else { return }
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.textOnAccent]
        standardAppearance.shadowColor = .clear
        standardAppearance.backgroundColor = .backgroundPrimary

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        navigationController?.navigationBar.compactAppearance = standardAppearance
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor)
        ])

        let shadowViewHeightConstraint = shadowView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadowViewHeightConstraint
        ])
        self.shadowViewHeightConstraint = shadowViewHeightConstraint

        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: shadowView.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension InAppPurchaseStoreViewController: InAppPurchaseStoreViewType {
    func presentError(_ error: PresentableMessageType, _ actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(error, actions: actions)
    }

    func setLoading() {
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }
        bottomStackView.addArrangedSubview(activityIndicatorView)
        activityIndicatorView.setAnimating(true)
        updateShadowView()
    }

    func setUnlinkedInAppPurchaseSubscription(connectAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.attributedText = NSAttributedString(string: L10n.Iap.Store.UnlinkedInapppurchase.headline, attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleCenteredTextAttributes)
        bottomStackView.addArrangedSubview(label)

        let connectAccountButton = BigButton()
        connectAccountButton.touchUpInsideActionClosure = connectAction
        connectAccountButton.style = .primary
        connectAccountButton.setTitle(L10n.Iap.Store.UnlinkedInapppurchase.linkButton, for: .normal)
        bottomStackView.addArrangedSubview(connectAccountButton)

        let cancelSubscriptionButton = BigButton()
        cancelSubscriptionButton.touchUpInsideActionClosure = cancelAction
        cancelSubscriptionButton.style = .welcome
        cancelSubscriptionButton.setTitle(L10n.Iap.Store.UnlinkedInapppurchase.cancelButton, for: .normal)
        bottomStackView.addArrangedSubview(cancelSubscriptionButton)
        updateShadowView()
    }

    func setActiveExternalSubscription() {
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.attributedText = NSAttributedString(string: L10n.Iap.Store.ExternalSubscription.headline, attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleCenteredTextAttributes)
        bottomStackView.addArrangedSubview(label)
        updateShadowView()
    }

    func showGenericError() {
        let retryActionButton = MessageAction(title: L10n.Generic.retry, style: .normal) { [presenter] in
            presenter.retryWasTapped()
            return true
        }
        let contactSupportActionButton = MessageAction(title: L10n.Support.title, style: .normal) { [presenter] in
            presenter.contactSupportWasTapped()
            return true
        }

        let presentableMessage = PresentableMessage(title: L10n.Error.Generic.title, description: L10n.Error.Generic.message, logLevel: .error)

        presentError(presentableMessage, [retryActionButton, contactSupportActionButton])
    }

    func setReadyToBuy(localizedPrice: String,
                       offer: String?,
                       subscribeAction: @escaping () -> Void,
                       reactivateAction: @escaping () -> Void) {
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        let subscriptionButton = BigButton()
        subscriptionButton.touchUpInsideActionClosure = subscribeAction
        subscriptionButton.style = .primary

        let paymentLabel = UILabel()
        paymentLabel.numberOfLines = 0
        paymentLabel.attributedText = NSAttributedString(string: L10n.Iap.Paywall.Payment.Info.title, attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleTextAttributes)
        mainStackView.addArrangedSubview(paymentLabel)

        if let offer = offer {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: L10n.Iap.Store.IdleInapppurchase.headline(offer), attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleCenteredTextAttributes)
            subscriptionButton.setTitle(L10n.Iap.Store.IdleInapppurchase.Subheadline.withFreeOffer(localizedPrice), for: .normal)
            bottomStackView.addArrangedSubview(label)
        } else {
            subscriptionButton.setTitle(L10n.Iap.Store.IdleInapppurchase.Subheadline.withoutFreeOffer(localizedPrice), for: .normal)
        }

        let reactivateButton = BigButton()
        reactivateButton.style = .welcome
        reactivateButton.setTitle(L10n.Iap.Store.IdleInapppurchase.restoreButton, for: .normal)
        reactivateButton.touchUpInsideActionClosure = reactivateAction
        bottomStackView.addArrangedSubview(subscriptionButton)
        bottomStackView.addArrangedSubview(reactivateButton)

        view.layoutSubviews()
        updateShadowView()
    }

    func setActiveInAppPurchaseSubscription(buttonAction: @escaping () -> Void) {
        bottomStackView.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.attributedText = NSAttributedString(string: L10n.Iap.Store.UnlinkedInapppurchase.headline, attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleCenteredTextAttributes)
        bottomStackView.addArrangedSubview(label)

        let cancelSubscriptionButton = BigButton()
        cancelSubscriptionButton.touchUpInsideActionClosure = buttonAction
        cancelSubscriptionButton.style = .primary
        cancelSubscriptionButton.setTitle(L10n.Iap.Store.UnlinkedInapppurchase.cancelButton, for: .normal)
        bottomStackView.addArrangedSubview(cancelSubscriptionButton)
        updateShadowView()
    }
}

private extension InAppPurchaseStoreViewController {

    private func updateShadowView() {
        shadowViewHeightConstraint?.constant = mainScrollView.contentSize.height > mainScrollView.bounds.height ? 1 : 0
    }

    private func createStaticInfoItemStackView(image: UIImage, titleString: String, subtitleString: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = 17
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .firstBaseline
        stackView.distribution = .fillProportionally

        let imageViewContainer = UIView()
        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        imageViewContainer.backgroundColor = .clear

        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.tintColor = .iconTertiary

        imageViewContainer.addSubview(imageView)
        imageView.pinTop(to: imageViewContainer, insets: .init(top: 4.0, left: 0, bottom: 0, right: 0))

        stackView.addArrangedSubview(imageViewContainer)

        let innerStack = UIStackView()
        innerStack.spacing = 2
        innerStack.axis = .vertical
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = NSAttributedString(string: titleString, attributes: ThemeManager.currentTheme.iAPStoreViewInfoTitleTextAttributes)

        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = NSAttributedString(string: subtitleString, attributes: ThemeManager.currentTheme.iAPStoreViewInfoSubtitleTextAttributes)

        innerStack.addArrangedSubview(titleLabel)
        innerStack.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(innerStack)

        return stackView
    }

    private func addTitleAndImage() {

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.attributedText = NSAttributedString(string: L10n.Iap.Paywall.title, attributes: ThemeManager.currentTheme.iAPStoreViewTitleTextAttributes)

        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 1
        subtitleLabel.attributedText = NSAttributedString(string: L10n.Iap.Paywall.subTitle, attributes: ThemeManager.currentTheme.iAPStoreViewSubtitleTextAttributes)

        let bigImageView = UIImageView()
        bigImageView.image = Asset.doctors.image
        bigImageView.contentMode = .scaleAspectFit
        bigImageView.translatesAutoresizingMaskIntoConstraints = false

        storeStaticInfoStackView.addArrangedSubview(titleLabel)
        storeStaticInfoStackView.addArrangedSubview(subtitleLabel)
        storeStaticInfoStackView.setCustomSpacing(16, after: subtitleLabel)

        storeStaticInfoStackView.addArrangedSubview(bigImageView)
        storeStaticInfoStackView.setCustomSpacing(16, after: bigImageView)
    }
}
