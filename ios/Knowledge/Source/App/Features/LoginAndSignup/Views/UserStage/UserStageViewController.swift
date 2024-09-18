//
//  UserStageViewController.swift
//  LoginAndSignup
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import DesignSystem
import Common
import Domain
import UIKit
import Localization

/// @mockable
public protocol UserStageViewType: AnyObject {
    func setViewData(_ viewData: UserStageViewData)
    func selectUserStage(_ userStage: UserStage)

    // Shows or hides the disclaimer. Per default the disclaimer is hidden
    func setDisclaimer(_ visibility: UserStageViewData.DisclaimerState, completion: @escaping () -> Void)
    func setIsLoading(_ isLoading: Bool)

    func presentMessage(_ message: PresentableMessageType)
    func showSaveNotification()
}

public class UserStageViewController: UIViewController, UserStageViewType {

    private var dataSource = UserStageTableViewDataSource(viewData: UserStageViewData(items: [], discalimerState: .hidden))

    @IBOutlet private var tableView: UITableView! {
        didSet {
            dataSource.setup(tableView)
            tableView.backgroundColor = .canvas
            tableView.dataSource = dataSource
            tableView.delegate = self
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.estimatedSectionFooterHeight = 50
            tableView.separatorStyle = .none
        }
    }

    private var presenter: UserStagePresenterType

    public init(presenter: UserStagePresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = L10n.UserStage.title
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
    }

    public func setViewData(_ viewData: UserStageViewData) {
        dataSource = UserStageTableViewDataSource(viewData: viewData)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    public func selectUserStage(_ userStage: UserStage) {
        guard let index = dataSource.index(for: userStage) else { return }
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }

    public func presentMessage(_ message: PresentableMessageType) {
        UIAlertMessagePresenter(presentingViewController: self).present(message, actions: [.dismiss])
    }

    public func setIsLoading(_ isLoading: Bool) {
        (tableView.footerView(forSection: 0) as? UserStageTableViewFooterView)?.setIsLoading(isLoading)
    }

    public func setDisclaimer(_ visibility: UserStageViewData.DisclaimerState, completion: @escaping () -> Void) {
        let footerView = tableView?.footerView(forSection: 0) as? UserStageTableViewFooterView
        UIView.animate(withDuration: 0.3, animations: { [weak footerView] in
            self.setDisclaimer(visibility: visibility, for: footerView, animated: true)
        }, completion: { _ in
            completion()
        })
    }

    private func setDisclaimer(visibility: UserStageViewData.DisclaimerState, for footer: UserStageTableViewFooterView?, animated: Bool) {
        var footerDisclaimer = NSAttributedString(string: "")

        switch visibility {
        case .shown(let disclaimer, let buttonTitle):
            footer?.setIsVisible(true)
            footerDisclaimer = disclaimer
            footer?.update(primaryButtonTitle: buttonTitle)
        case .hidden:
            footer?.setIsVisible(false)
        case .onlyButtonShown(let buttonTitle):
            footer?.setOnlyButtonVisible()
            footer?.update(primaryButtonTitle: buttonTitle)
        }

        // only update the disclaimer if the text is not empty
        if !footerDisclaimer.string.isEmpty {
            if animated {
                tableView.performBatchUpdates { [weak footer] in
                    footer?.update(disclaimer: footerDisclaimer)
                }
            } else {
                footer?.update(disclaimer: footerDisclaimer)
            }
        }
    }
    public func showSaveNotification() {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.attributedText = NSAttributedString(string: L10n.UserStage.Savenotification.title, attributes: ThemeManager.currentTheme.footerViewTextAttributes)
        label.sizeToFit()

        let container = UIView(frame: .init(origin: .zero, size: .init(width: label.bounds.width + 20, height: label.bounds.height + 8)))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        container.backgroundColor = .backgroundAccentSubtle
        container.layer.masksToBounds = true
        container.layer.cornerRadius = container.bounds.height / 2.0

        container.addSubview(label)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -2),

            container.widthAnchor.constraint(equalToConstant: container.bounds.width),
            container.heightAnchor.constraint(equalToConstant: container.bounds.height),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 24)
        ])

        UIView.animate(withDuration: 0.3, animations: { container.alpha = 1 }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 3, animations: { container.alpha = 0 }, completion: { _ in
                container.removeFromSuperview()
            })
        })
    }
}

extension UserStageViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .attributedString(with: L10n.UserStage.header,
                                                 style: .paragraphBold,
                                                 decorations: [.color(.textSecondary)])
        let view = UIView()
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])

        return view
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        64
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = UserStageTableViewFooterView.fromNib() else { return nil }
        footerView.delegate = self
        setDisclaimer(visibility: dataSource.initialDisclaimerVisisbility, for: footerView, animated: false)
        return footerView
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.item(at: indexPath.row) else { return }
        presenter.didSelectUserStage(item.stage)
    }
}

extension UserStageViewController: UserStageTableViewFooterViewDelegate {

    public func agreementSwitchDidChange(sender: UISwitch) {
        if let footerView = tableView.footerView(forSection: 0) {
            tableView.scrollRectToVisible(footerView.frame, animated: true)
        }
    }

    public func agreementTapped(url: URL) {
        presenter.agreementTapped(url: url)
    }

    public func primaryButtonTapped() {
        presenter.primaryButtonTapped()
    }
}
