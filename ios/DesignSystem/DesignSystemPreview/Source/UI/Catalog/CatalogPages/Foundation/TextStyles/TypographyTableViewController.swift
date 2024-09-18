//
//  TypographyTableViewController.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 12.04.23.
//

import DesignSystem
import UIKit

class TypographyTableViewController: UITableViewController {
    let quote = String.randomQuote()
    let styles = TextStyle.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.canvas
        title = "Typography"
        registerCells()
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "styleCell" )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        styles.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        styles[section].rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "styleCell")!
        let style = styles[indexPath.section]
        var configuration = cell.defaultContentConfiguration()
        configuration.attributedText = .attributedString(with: quote, style: style)
        cell.contentConfiguration = configuration
        cell.selectionStyle = .none
        return cell
    }
}
