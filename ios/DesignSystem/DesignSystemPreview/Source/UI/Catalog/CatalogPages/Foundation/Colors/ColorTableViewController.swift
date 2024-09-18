//
//  ColorViewController.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import DesignSystem
import UIKit

class ColorTableViewController: UITableViewController {

    private let titles = ["Light", "Dark", "Dynamic"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.canvas
        title = "Palette"
        registerCells()
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell" )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell")!

        var configuration = cell.defaultContentConfiguration()
        configuration.attributedText = .attributedString(with: titles[indexPath.row], style: .paragraph)
        cell.contentConfiguration = configuration
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(DynamicThemeViewController(override: .light), animated: true)
        case 1:
            navigationController?.pushViewController(DynamicThemeViewController(override: .dark), animated: true)
        default:
            navigationController?.pushViewController(DynamicThemeViewController(), animated: true)
            print("")
        }
    }

}
