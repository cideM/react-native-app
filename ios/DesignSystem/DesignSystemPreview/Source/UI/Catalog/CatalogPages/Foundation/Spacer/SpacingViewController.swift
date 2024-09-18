//
//  SpacingViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 28.07.23.
//


import UIKit
import DesignSystem

private struct Catalog {

    static let pageCellIdentifier = "de.amboss.com.page.cell.identifier"

    static let pages = [("None", Spacing.none),
                        ("XXXS", Spacing.xxxs),
                        ("XXS", Spacing.xxs),
                        ("XS", Spacing.xs),
                        ("S", Spacing.s),
                        ("M", Spacing.m),
                        ("L", Spacing.l),
                        ("XL", Spacing.xl),
                        ("XXL", Spacing.xxl)]
}

class SpacingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.backgroundColor = .canvas
        title = "Spacing"
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

        let colorCube = Spacer.with(height: val)
        cell.contentView.addSubview(colorCube)

        colorCube.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
        colorCube.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        colorCube.widthAnchor.constraint(equalToConstant: 150).isActive = true
        colorCube.heightAnchor.constraint(equalToConstant: val).isActive = true

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
