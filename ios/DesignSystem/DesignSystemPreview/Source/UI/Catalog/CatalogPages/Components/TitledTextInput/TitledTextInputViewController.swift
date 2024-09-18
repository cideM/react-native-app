//
//  TitledTextInputViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 23.11.23.
//

import UIKit
import DesignSystem

private struct Page {
    static let cellIdentifier = "de.amboss.titledTextInput.cell.reuseidentifier"
}

class TitledTextInputViewController: UITableViewController, LabledWrapperViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    private func setUp() {
        view.backgroundColor = .canvas
        title = "Titled Text Input Fields"
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Page.cellIdentifier)
    }

    // MARK: TableView Delegate / DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Page.cellIdentifier)!
        cell.contentView.subviews.forEach{ $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .canvas

        switch indexPath.row {
        case 0:
            let textField = LabeledWrapperView<TextInputField>()
            textField.title = "Placeholder Text"
            textField.inputTextField.placeholder = "Dynamic titled text field - Type in me!"
            cell.contentView.addSubview(textField)
            textField.pin(to: cell.contentView, insets: .init(horizontal: 10.0, vertical: 10))
        case 1:
            let textField = LabeledWrapperView<TextInputField>()
            textField.title = "Placeholder Text"
            textField.inputTextField.text = "Invalid input example - QA only"
            textField.isUserInteractionEnabled = false
            textField.inputTextField.validator = EndlessStringValidator()
            textField.delegate = self
            cell.contentView.addSubview(textField)
            textField.pin(to: cell.contentView, insets: .init(horizontal: 10.0, vertical: 10))
        case 2:
            let textField = LabeledWrapperView<TextInputField>()
            textField.title = "Placeholder Text"
            textField.inputTextField.placeholder = "Error State"
            textField.inputTextField.validator = InputStringMinimumCountValidator()
            textField.delegate = self
            cell.contentView.addSubview(textField)
            textField.pin(to: cell.contentView, insets: .init(horizontal: 10.0, vertical: 10))
            
        default:
            return cell
        }

        return cell
    }

    func willDisplayErrorView(isVisible: Bool) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
