//
//  ComponentsViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 25.07.23.
//

import DesignSystem
import UIKit

private enum Rows: String, CaseIterable {
    case contentCards = "Content Cards"
    case calloutView = "Callout View"
    case textInputView = "Text Input View"
    case titledTextInputView = "Titled Text Input View"
    case buttons = "Buttons"
    case tabsControl = "TabsControl"

    static func rowNameByIndex(_ index: Int) -> String {
        return Rows.allCases[index].rawValue
    }

    static func indexByCase(_ caseValue: Rows) -> Int {
        return Rows.allCases.firstIndex(of: caseValue) ?? 0
    }
}

class ComponentsViewController: UITableViewController {

    private let viewName = "Components"

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
        navigationController?.tabBarItem.image = UIImage(systemName: "c.square")
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
        case Rows.indexByCase(.contentCards):
            let presenter = ContentCardsPresenter()
            let dataSource = ContentCardsDataSource()
            let genericController = GenericListTableViewController(dataSource: dataSource, presenter: presenter)
            navigationController?.pushViewController(genericController, animated: true)
        case Rows.indexByCase(.calloutView):
            let presenter = CalloutViewPresenter()
            let dataSource = CalloutViewDataSource()
            let genericController = GenericListTableViewController(dataSource: dataSource, presenter: presenter)
            navigationController?.pushViewController(genericController, animated: true)
        case Rows.indexByCase(.textInputView):
            let vc = TextInputFieldViewController()
            navigationController?.pushViewController(vc, animated: true)
        case Rows.indexByCase(.titledTextInputView):
            let vc = TitledTextInputViewController()
            navigationController?.pushViewController(vc, animated: true)
        case Rows.indexByCase(.buttons):
            let vc = ButtonsViewController()
            navigationController?.pushViewController(vc, animated: true)
        case Rows.indexByCase(.tabsControl):
            let vc = TabsControlViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("Default")
        }
    }
}
