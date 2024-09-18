//
//  ExtensionListViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol ExtensionViewType: AnyObject {
    func setExtensions(_ extensions: [ExtensionViewData])
}

final class ExtensionListViewController: UITableViewController, ExtensionViewType {

    private var extensions: [ExtensionViewData] = []
    private let presenter: ExtensionPresenterType

    init(presenter: ExtensionPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        presenter.view = self
        let nib = UINib(nibName: "ExtensionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ExtensionTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }

    func setExtensions(_ extensions: [ExtensionViewData]) {
        self.extensions = extensions
        tableView.reloadData()
    }
}

extension ExtensionListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        extensions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewData = extensions[indexPath.item]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExtensionTableViewCell.reuseIdentifier, for: indexPath) as? ExtensionTableViewCell else { return UITableViewCell() }
        cell.configure(title: viewData.learningCard?.title, notes: viewData.ext?.unformattedNote)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewData = extensions[indexPath.item]
        guard let learningCard = viewData.learningCard?.learningCardIdentifier, let sectionIdentifier = viewData.ext?.section.value else { return }
        presenter.deepLink(to: LearningCardDeeplink(learningCard: learningCard, anchor: LearningCardAnchorIdentifier(sectionIdentifier), particle: nil, sourceAnchor: nil))
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
