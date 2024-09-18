//
//  DynamicThemeViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 05.09.23.
//

import DesignSystem
import UIKit

class DynamicThemeViewController: UITableViewController {

    private let colors: [ThemeColors] = ThemeColors.allCases

    init(override userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = userInterfaceStyle
    }
    
    @available(*, unavailable)  required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas

        switch overrideUserInterfaceStyle {
        case .dark: title = "Dark"
        case .light: title = "Light"
        default: title = "Dynamic"
        }

        registerCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure navbar and tabbar mathc the style ...
        // UIApplication.shared.windows.first?.overrideUserInterfaceStyle = overrideUserInterfaceStyle
        UIApplication.activeKeyWindow?.overrideUserInterfaceStyle = overrideUserInterfaceStyle
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Roll back to system style ...
        UIApplication.activeKeyWindow?.overrideUserInterfaceStyle = .unspecified
    }

    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "colorCell" )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell")!

        let name = colors[indexPath.row].rawValue.capitalizingFirstLetter()
        let color = colors[indexPath.row].value()

        var configuration = cell.defaultContentConfiguration()
        configuration.attributedText = .attributedString(with: name,
                                                         style: .paragraph)

        let circleImage = Circle.with(color: color).image()

        configuration.image = circleImage

        configuration.secondaryTextProperties.color = .secondaryLabel

        if color.rgba.alpha != 1 {
            let formattedAlpha = String(format: "%.2f", color.rgba.alpha)
            configuration.secondaryAttributedText = .attributedString(with: "\(color.hexString) (\(formattedAlpha))",
                                                                      style: .paragraph)
        } else {
            configuration.secondaryAttributedText = .attributedString(with: color.hexString,
                                                                      style: .paragraph)
        }
        cell.contentConfiguration = configuration

        let colorCube = Square.with(color: color)
        cell.contentView.addSubview(colorCube)
        colorCube.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
        colorCube.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
        colorCube.widthAnchor.constraint(equalToConstant: 80).isActive = true
        colorCube.heightAnchor.constraint(equalToConstant: 80).isActive = true

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
}

fileprivate extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

