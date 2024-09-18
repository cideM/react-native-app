//
//  RoutedTableViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 31.07.23.
//

import DesignSystem
import UIKit

public class RoutedTableViewSectionController: UITableViewController {

    // MARK: - Reload All Section
    var sections: [RoutedTableViewSectionType] {
        didSet {
            connectTableViewWithSections()
            registerCellTypes()
            tableView.reloadData()
        }
    }

    // MARK: - Initialization
    init(sections: [RoutedTableViewSectionType] = []) {
        self.sections = sections
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewLifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        tableView.reloadData()
    }

    // MARK: - Setup
    public func setup() {
        connectTableViewWithSections()
        registerCellTypes()
    }

    private func connectTableViewWithSections() {
        for section in sections {
            section.tableView = tableView
        }
    }

    private func registerCellTypes() {
        for section in sections {
            section.registerCellTypes()
        }
    }

    // MARK: - UITableViewDataSource
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let obj = sections[section]
        return obj.tableView(tableView, numberOfRowsInSection: section)
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = sections[indexPath.section]
        return obj.tableView(tableView, cellForRowAt: indexPath)
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = sections[indexPath.section]
        return obj.tableView?(tableView, heightForRowAt: indexPath) ?? 44.0
    }

    // MARK: - UITAbleViewDelegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
