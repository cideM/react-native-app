//
//  MiniMapViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 31.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol MiniMapViewType: AnyObject {
    func set(items: [MiniMapViewItem])
}

final class MiniMapTableViewController: UITableViewController, MiniMapViewType {

    private var items = [MiniMapViewItem]()
    private let presenter: MiniMapPresenterType

    init(presenter: MiniMapPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MiniMapTableViewCell.self, forCellReuseIdentifier: MiniMapTableViewCell.reuseIdentifier)
        presenter.view = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude)
    }

    func set(items: [MiniMapViewItem]) {
        self.items = items
        tableView.reloadData()
    }
}

extension MiniMapTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MiniMapTableViewCell.reuseIdentifier, for: indexPath) as? MiniMapTableViewCell else { return UITableViewCell() }
        let item = items[indexPath.item]
        switch item.itemType {
        case .parent:
            cell.set(title: NSMutableAttributedString(string: item.miniMapNode.title, attributes: ThemeManager.currentTheme.miniMapParentTitleTextAttributes))
            return cell
        case .child:
            cell.set(title: NSMutableAttributedString(string: item.miniMapNode.title, attributes: ThemeManager.currentTheme.miniMapChildTitleTextAttributes), image: Asset.Icon.minimapCircle.image)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectItem(items[indexPath.item])
    }
}
