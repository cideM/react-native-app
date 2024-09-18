//
//  CornerRadiusViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 28.07.23.
//

import UIKit
import DesignSystem

private struct Catalog {

    static let pageCellIdentifier = "de.amboss.com.page.cell.identifier"
    static let pages = [("None", Radius.none),
                        ("XS", Radius.xs),
                        ("S", Radius.s),
                        ("M", Radius.m),
                        ("L", Radius.l),
                        ("XL", Radius.xl)]
}

class CornerRadiusViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.backgroundColor = .canvas
        title = "Corner Radius"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Catalog.pageCellIdentifier)
    }

    // MARK: TableView Delegate / DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Catalog.pages.count
    }

    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Catalog.pageCellIdentifier)!
        cell.selectionStyle = .none
        let (label, val) = Catalog.pages[indexPath.row]

        var configuration = cell.defaultContentConfiguration()
        configuration.attributedText = .attributedString(with: label, style: .paragraph)
        cell.contentConfiguration = configuration
        cell.backgroundColor = .backgroundPrimary
        let colorCube = Square.with(color: UIColor.backgroundAccent, cornerRadius: val)
        cell.contentView.addSubview(colorCube)
        colorCube.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
        colorCube.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
        colorCube.widthAnchor.constraint(equalToConstant: 80).isActive = true
        colorCube.heightAnchor.constraint(equalToConstant: 80).isActive = true

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
