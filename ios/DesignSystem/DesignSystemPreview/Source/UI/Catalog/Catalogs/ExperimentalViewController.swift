//
//  ExperimentalViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 25.07.23.
//

import DesignSystem
import UIKit

private enum Rows: String, CaseIterable {
    case loginView = "LoginView"

    static func rowNameByIndex(_ index: Int) -> String {
        return Rows.allCases[index].rawValue
    }

    static func indexByCase(_ caseValue: Rows) -> Int {
        return Rows.allCases.firstIndex(of: caseValue) ?? 0
    }
}


class ExperimentalViewController: UITableViewController {

    private let viewName = "Experimental"

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .canvas
        title = viewName

        registerCells()
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
        case Rows.indexByCase(.loginView):
            let vc = LoginViewController_Experimental()
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
        default:
            print("Default")
        }
    }
}

