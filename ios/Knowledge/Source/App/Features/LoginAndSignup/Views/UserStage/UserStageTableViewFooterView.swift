//
//  UserStageTableViewFooterView.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 05.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DesignSystem
import Common
import Domain
import UIKit

public protocol UserStageTableViewFooterViewDelegate: AnyObject {
    func agreementTapped(url: URL)
    func primaryButtonTapped()
    func agreementSwitchDidChange(sender: UISwitch)
}

public protocol UserStageTableViewFooterViewType {
    func update(disclaimer: NSAttributedString)
    func update(primaryButtonTitle: String)
    func setIsLoading(_ isLoading: Bool)
    func setIsVisible(_ isVisible: Bool)
}

public final class UserStageTableViewFooterView: UITableViewHeaderFooterView, UserStageTableViewFooterViewType {
    weak var delegate: UserStageTableViewFooterViewDelegate? {
        didSet {
            primaryButton.touchUpInsideActionClosure = { [weak self] in
                self?.delegate?.primaryButtonTapped()
            }
        }
    }

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    @IBOutlet private var agreementsAcceptanceSwitch: UISwitch! {
        didSet {
            agreementsAcceptanceSwitch.onTintColor = .backgroundAccent
        }
    }
    @IBOutlet private var agreementsLabel: LinkAwareLabel! {
        didSet {
            agreementsLabel.tintColor = .textAccent
            agreementsLabel.linkTapCallback = { [weak self] url in
                self?.delegate?.agreementTapped(url: url)
            }
        }
    }

    @IBOutlet private var primaryButton: PrimaryButton! {
        didSet {
            primaryButton.isEnabled = false
            primaryButton.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: primaryButton.centerYAnchor).isActive = true
        }
    }
    @IBOutlet private var agreementsStackView: UIStackView!

    @IBOutlet private var mainStackView: UIStackView!

    @IBOutlet private var mainStackViewTopConstraint: NSLayoutConstraint!

    @IBAction private func agreementsAcceptanceSwitchValueChanged(_ sender: UISwitch) {
        primaryButton.isEnabled = agreementsAcceptanceSwitch.isOn
        delegate?.agreementSwitchDidChange(sender: sender)
    }

    public func update(disclaimer: NSAttributedString) {
        agreementsLabel.attributedText = disclaimer
        mainStackViewTopConstraint.constant = 16
        agreementsAcceptanceSwitch.setOn(false, animated: false)
    }

    public func update(primaryButtonTitle: String) {
        primaryButton.isEnabled = false
        primaryButton.title = primaryButtonTitle.uppercased()
    }
    public func setIsLoading(_ isLoading: Bool) {
        primaryButton.isEnabled = !isLoading
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }

    public func setIsVisible(_ isVisible: Bool) {
        agreementsStackView.alpha = 1
        mainStackView.alpha = isVisible ? 1.0 : 0.0
    }

    public func setOnlyButtonVisible() {
        mainStackView.alpha = 1
        agreementsStackView.alpha = 0
        primaryButton.alpha = 1
    }
}

extension UserStageTableViewFooterView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.agreementTapped(url: URL)
        return false
    }
}
