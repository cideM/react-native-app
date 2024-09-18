//
//  AccountSettingsViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 07.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol AccountSettingsViewType: AnyObject {
    func setEmail(_ email: String)
    func presentMessage(title: String, message: String, actions: [MessageAction])
}

final class AccountSettingsViewController: UITableViewController {

    @IBOutlet private weak var tableViewCell: UITableViewCell!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private var logoutButton: BigButton! {
        didSet {
            logoutButton.style = .primary
        }
    }
    @IBOutlet private var deleteAccountButton: BigButton! {
        didSet {
            deleteAccountButton.style = .link
        }
    }

    private var presenter: AccountSettingsPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    @IBAction private func logoutButtonTapped(_ sender: BigButton) {
        presenter.logoutButtonTapped()
    }

    @IBAction private func deleteAccountButtonTapped(_ sender: BigButton) {
        presenter.deleteAccountButtonTapped()
    }

    static func viewController(with presenter: AccountSettingsPresenter) -> AccountSettingsViewController {
        let storyboard = UIStoryboard(name: "AccountSettings", bundle: nil)
        let accountSettingsViewController = storyboard.instantiateViewController(withIdentifier: "AccountSettingsViewController") as! AccountSettingsViewController // swiftlint:disable:this force_cast
        accountSettingsViewController.presenter = presenter
        return accountSettingsViewController
    }

    /// Private init to protect the view from  crashing as we need to initilise presenter: instead viewController(with presenter: AccountSettingsPresenter) should be called
    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        title = L10n.AccountSettings.Account.title
        navigationItem.backBarButtonItem?.title = ""

        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor

        logoutButton.setTitle(L10n.AccountSettings.LogoutButton.title, for: [])
        deleteAccountButton.setTitle(L10n.AccountSettings.DeleteAccountButton.title, for: [])
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        56
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: L10n.AccountSettings.Account.title, attributes: ThemeManager.currentTheme.headerTextAttributes)

        let view = UIView()
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.5)
        ])

        return view
    }
}

extension AccountSettingsViewController: AccountSettingsViewType {
    func setEmail(_ email: String) {
        emailLabel.attributedText = NSAttributedString(string: email, attributes: ThemeManager.currentTheme.emailTextViewBoldTextAttributes)
    }

    func presentMessage(title: String, message: String, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(title: title, message: message, actions: actions)
    }
}
