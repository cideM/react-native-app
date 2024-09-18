//
//  PluginListTableViewController.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import DeveloperOverlay
import UIKit

class PluginListTableViewController: UITableViewController {

    let plugins: [DebuggerPlugin]

    init(plugins: [DebuggerPlugin]) {
        self.plugins = plugins
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "CELL")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plugins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plugin = self.plugin(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = plugin.title
        cell.detailTextLabel?.numberOfLines = 4
        cell.detailTextLabel?.text = plugin.description
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = plugin(at: indexPath).viewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }

    private func plugin(at indexPath: IndexPath) -> DebuggerPlugin {
        guard indexPath.row < plugins.count else {
            fatalError("Index out of bounds (\(indexPath.row) should > \(plugins.count)")
        }
        return plugins[indexPath.row]
    }
}
