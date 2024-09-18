//
//  UsagePurposeViewController.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

/// @mockable
protocol UsagePurposeViewType: AnyObject {
    func setUsagePurposes(_ usagePurposes: [UsagePurpose])
}

final class UsagePurposeViewController: UIViewController, UsagePurposeViewType {
    private let presenter: UsagePurposePresenterType

    private var usagePurposes: [UsagePurpose] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let usagePurposeTableViewCellIdentifier = "usagePurposeTableViewCellIdentifier"
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .canvas
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: usagePurposeTableViewCellIdentifier)
        return tableView
    }()

    init(presenter: UsagePurposePresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.UsagePurpose.title
        view.addSubview(tableView)
        tableView.constrainEdges(to: view)

        presenter.view = self
    }

    func setUsagePurposes(_ usagePurposes: [UsagePurpose]) {
        self.usagePurposes = usagePurposes
    }
}

extension UsagePurposeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usagePurposes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: usagePurposeTableViewCellIdentifier, for: indexPath)
        cell.backgroundColor = .backgroundPrimary
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = NSAttributedString(string: usagePurposes[indexPath.row].description, attributes: ThemeManager.currentTheme.usagePurposeCellTitleTextAttributes)
        return cell
    }
}

extension UsagePurposeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < usagePurposes.count else { return }
        presenter.didSelectUsagePurpose(usagePurposes[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: "What do you plan to use AMBOSS for?", attributes: ThemeManager.currentTheme.headerTextAttributes)

        let view = UIView()
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.5)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        56
    }
}
