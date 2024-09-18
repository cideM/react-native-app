//
//  KeyValueDebugger.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class KeyValueDebuggerRootViewController: UITableViewController {

    internal var datasource: KeyValueTableViewDatasource {
        didSet {
            tableView.dataSource = datasource
            tableView.reloadData()
        }
    }
    internal var searchDataSource: KeyValueTableViewDatasource? {
        didSet {
            if let searchDataSource = searchDataSource {
                tableView.dataSource = searchDataSource
                tableView.reloadData()
            } else {
                tableView.dataSource = datasource
                tableView.reloadData()
            }
        }
    }

    private let sectionsGenerator: () -> ([KeyValueSection])
    private let searchController = UISearchController(searchResultsController: nil)

    public init(sectionsGenerator: @escaping @autoclosure () -> ([KeyValueSection])) {
        self.sectionsGenerator = sectionsGenerator
        datasource = KeyValueTableViewDatasource([])
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datasource = KeyValueTableViewDatasource(sectionsGenerator())
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchDataSource?.item(at: indexPath) ?? datasource.item(at: indexPath)
        guard let viewController = detailViewController(for: item) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func detailViewController(for item: KeyValueItem) -> UIViewController? {
        guard case let .editable(editableValue) = item.value else { return nil }
        switch editableValue {
        case .bool(let value, let setter):
            return KeyValueDebuggerBoolDetailViewController(key: item.key, value: value(), onChange: setter)
        case .string(let value, let setter):
            return KeyValueDebuggerStringDetailViewController(key: item.key, value: value(), onChange: setter)
        case .int(let value, let setter):
            return KeyValueDebuggerIntDetailViewController(key: item.key, value: value(), onChange: setter)
        case .date(let value, let setter):
            return KeyValueDebuggerDateDetailViewController(key: item.key, value: value(), onChange: setter)
        }
    }
}

extension KeyValueDebuggerRootViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchBar.text?.lowercased() ?? ""
        if search.isEmpty {
            searchDataSource = nil
        } else {
            let filteredSections: [KeyValueSection] = datasource.sections.map { section in
                let filteredItems = section.items.filter { item -> Bool in
                    item.key.lowercased().contains(search)
                }
                return KeyValueSection(title: section.title, items: filteredItems)
            }
            searchDataSource = KeyValueTableViewDatasource(filteredSections)
        }
    }
}
