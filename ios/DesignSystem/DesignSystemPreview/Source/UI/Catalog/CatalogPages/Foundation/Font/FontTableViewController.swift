//
//  FontViewController.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 12.04.23.
//

import DesignSystem
import UIKit

class FontTableViewController: UITableViewController {
    let quote = String.alllCharacters()
    let fonts: [UIFont] = [
        .font(family: .lato, weight: .regular, size: .headerM),
        .font(family: .lato, weight: .bold, size: .headerM),
        .font(family: .lato, weight: .black, size: .headerM),
    ].compactMap{ $0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.canvas
        title = "Font"
        registerCells()
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fontCell" )
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fonts.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fonts[section].fontName
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontCell")!
        cell.selectionStyle = .none
        var configuration = cell.defaultContentConfiguration()
        configuration.text = quote
        configuration.textProperties.font = fonts[indexPath.section]
        cell.contentConfiguration = configuration
        return cell
    }
}
