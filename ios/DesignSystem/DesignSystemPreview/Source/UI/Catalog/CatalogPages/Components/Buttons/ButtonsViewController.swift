//
//  ButtonsViewController.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 17.05.23.
//

import DesignSystem
import UIKit

private struct Page {
    static let cellIdentifier = "de.amboss.buttons.cell.reuseidentifier"
}

class ButtonsViewController: UITableViewController {

    override func viewDidLoad() {
        view.backgroundColor = .canvas
        title = "Buttons"
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Page.cellIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        16
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Page.cellIdentifier)!
        cell.contentView.subviews.forEach{ $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .canvas

        if indexPath.row == 0 {
            let button = PrimaryButton()
            button.title = "Button Primary"
            button.iconType = .informational
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 1 {
            let button = PrimaryButton()
            button.title = "Button Primary"
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 2 {
            let button = PrimaryButton()
            button.title = "Button Primary"
            button.iconType = .activityIndicator
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 3 {
            let button = PrimaryButton()
            button.title = "Button Primary (Disabled)"
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 4 {
            let button = SecondaryButton(mode: .onPrimaryBackgroundColor)
            button.title = "Button Secondary"
            button.iconType = .informational
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 5 {
            let button = SecondaryButton(mode: .onPrimaryBackgroundColor)
            button.title = "Button Secondary"
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 6 {
            let button = SecondaryButton(mode: .onPrimaryBackgroundColor)
            button.title = "Button Secondary"
            button.iconType = .activityIndicator
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 7 {
            let button = SecondaryButton(mode: .onPrimaryBackgroundColor)
            button.title = "Button Secondary (Disabled)"
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 8 {
            let button = TertiaryButton()
            button.title = "Button Tertiary"
            button.iconType = .informational
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 9 {
            let button = TertiaryButton()
            button.title = "Button Tertiary"
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 10 {
            let button = TertiaryButton()
            button.title = "Button Tertiary"
            button.iconType = .activityIndicator
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 11 {
            let button = TertiaryButton()
            button.title = "Button Tertiary (Disabled)"
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 12 {
            let button = DestructiveButton()
            button.title = "Button Destructive"
            button.iconType = .informational
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 13 {
            let button = DestructiveButton()
            button.title = "Button Destructive"
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 14 {
            let button = DestructiveButton()
            button.title = "Button Destructive"
            button.iconType = .activityIndicator
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }
        if indexPath.row == 15 {
            let button = DestructiveButton()
            button.title = "Button Destructive (Disabled)"
            button.isEnabled = false
            cell.contentView.addSubview(button)
            button.pin(to: cell.contentView, insets: .init(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0))
        }

        return cell
    }
}
