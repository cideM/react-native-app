//
//  PageViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 25.07.23.
//

import DesignSystem
import UIKit

private enum Rows: String, CaseIterable {
    case experimental = "Experimental"

    static func rowNameByIndex(_ index: Int) -> String {
        return Rows.allCases[index].rawValue
    }

    static func indexByCase(_ caseValue: Rows) -> Int {
        return Rows.allCases.firstIndex(of: caseValue) ?? 0
    }
}


class PageViewController: UITableViewController {

    private let viewName = "Pages"

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .canvas
        title = viewName

        registerCells()
    }

    override func willMove(toParent parent: UIViewController?) {
        navigationController?.tabBarItem.image = UIImage(systemName: "p.square")
        navigationController?.tabBarItem.title = viewName
        super.willMove(toParent: parent)
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self) )
    }

    // MARK: - UITableView DataSource and Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))!

        var configuration = cell.defaultContentConfiguration()
        configuration.attributedText = .attributedString(with: Rows.rowNameByIndex(indexPath.row),
                                                         style: .paragraph)
        cell.contentConfiguration = configuration
        cell.backgroundColor = .backgroundPrimary

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case Rows.indexByCase(.experimental):
            let vc = ExperimentalViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("Default")
        }
    }
}
