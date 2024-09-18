//
//  FoundationViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 25.07.23.
//

import DesignSystem
import UIKit

private enum Rows: String, CaseIterable {
    case color = "Color"
    case fonts = "Font"
    case textStyle = "Typography"
    case assets = "Assets"
    case spacer = "Spacing"
    case radius = "Radius"

    static func rowNameByIndex(_ index: Int) -> String {
        return Rows.allCases[index].rawValue
    }

    static func indexByCase(_ caseValue: Rows) -> Int {
        return Rows.allCases.firstIndex(of: caseValue) ?? 0
    }
}

class FoundationViewController: UITableViewController {

    private let viewName = "Foundation"

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
        navigationController?.tabBarItem.image = UIImage(systemName: "f.square")
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
        configuration.attributedText = .attributedString(with: Rows.rowNameByIndex(indexPath.row), style: .paragraph)
        cell.contentConfiguration = configuration
        cell.backgroundColor = .backgroundPrimary

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case Rows.indexByCase(.color):
            navigationController?.pushViewController(ColorTableViewController(), animated: true)
        case Rows.indexByCase(.fonts):
            navigationController?.pushViewController(FontTableViewController(), animated: true)
        case Rows.indexByCase(.textStyle):
            navigationController?.pushViewController(TypographyTableViewController(), animated: true)
        case Rows.indexByCase(.assets):
            print("Assets")
        case Rows.indexByCase(.spacer):
            navigationController?.pushViewController(SpacingViewController(), animated: true)
        case Rows.indexByCase(.radius):
            navigationController?.pushViewController(CornerRadiusViewController(), animated: true)
        default:
            print("Default")
        }
    }
}
