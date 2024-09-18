//
//  AmbossAcknowledeListViewController.swift
//  Knowledge
//
//  Created by Elmar Tampe on 07.09.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import AcknowList
import UIKit

// This class is just used to add our own styled tableViewCells.
// Quick and dirty, sorry for that. :D
class AmbossAcknowledeListViewController: AcknowListViewController {

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the cell before use it
        let identifier = String(describing: ColorThemeAwareUITableViewCell.self)
        tableView.register(ColorThemeAwareUITableViewCell.self, forCellReuseIdentifier: identifier)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: ColorThemeAwareUITableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let acknowledgement = acknowledgements[(indexPath as NSIndexPath).row] as Acknow?,
           let textLabel = cell.textLabel as UILabel? {
            textLabel.text = acknowledgement.title
            if canOpen(acknowledgement) {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            } else {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
        }

        return cell
    }

    private func canOpen(_ acknowledgement: Acknow) -> Bool {
        acknowledgement.text != nil || canOpenRepository(for: acknowledgement)
    }

    private func canOpenRepository(for acknowledgement: Acknow) -> Bool {
        guard let scheme = acknowledgement.repository?.scheme else {
            return false
        }

        return scheme == "http" || scheme == "https"
    }
}
