//
//  ThemeDebugger.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 04.10.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Common
import DeveloperOverlay
import UIKit

class ThemeDebugger: DebuggerPlugin {

    let title = "Theme"
    let description: String? = nil

    private let theme: Theme

    init(theme: Theme = ThemeManager.currentTheme) {
        self.theme = theme
    }

    func viewController() -> UIViewController {
        ThemeViewController(theme: theme)
    }

}

class ThemeViewController: UIViewController {

    struct Item {
        let attributes: [NSAttributedString.Key: Any]
        let title: String
    }

    private var stylesByFontSize = [Int: [Item]]()

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.register(ThemeCell.self, forCellReuseIdentifier: ThemeCell.reuseIdentifier)
        view.rowHeight = UITableView.automaticDimension
        return view
    }()

    init(theme: Theme) {
        let mirror = Mirror(reflecting: theme)

        for child in mirror.children {
            guard let attributes = child.value as? [NSAttributedString.Key: Any],
                  let title = child.label else { continue }
            if let size = (attributes[.font] as? UIFont)?.pointSize {
                var styles = stylesByFontSize[Int(size)] ?? []
                styles.append(Item(attributes: attributes, title: title))
                stylesByFontSize[Int(size)] = styles
            }
        }

        // Finding duplicate [NSAttributedString.Key: Any]
//        var duplicates = Set<[String]>()
//        for (_, value) in attributes {
//            let filtered = attributes.filter { _, value2 in value2.debugDescription == value.debugDescription }
//            let titles = filtered.map { $0.0 }
//            if titles.count > 1 {
//                duplicates.insert(titles)
//            }
//        }

        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = tableView
        tableView.dataSource = self
    }

    @available(*, unavailable)  required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ThemeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        stylesByFontSize.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let size = stylesByFontSize.keys.sorted()[section]
        return String(describing: size)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let size = stylesByFontSize.keys.sorted()[section]
        return stylesByFontSize[size]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThemeCell.reuseIdentifier, for: indexPath)
        guard let themeCell = cell as? ThemeCell  else { return cell }

        let size = stylesByFontSize.keys.sorted()[indexPath.section]
        if let item = stylesByFontSize[size]?[indexPath.row] {
            var config = themeCell.defaultContentConfiguration()

            config.secondaryTextProperties.color = .tertiaryLabel
            config.textProperties.numberOfLines = 0

            config.attributedText = NSAttributedString(string: "The quick brown fox jumps over the lazy dog", attributes: item.attributes)
            config.secondaryText = item.title
            themeCell.contentConfiguration = config
        }

        return themeCell
    }
}

private class ThemeCell: UITableViewCell {

    static let reuseIdentifier = "themeCell"

}
#endif
