//
//  TextInputFieldViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 23.11.23.
//

import UIKit
import DesignSystem

private struct Page {
    static let cellIdentifier = "de.amboss.textinputfield.cell.reuseidentifier"
}

class TextInputFieldViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    private func setUp() {
        view.backgroundColor = .canvas
        title = "Text Input Fields"
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Page.cellIdentifier)
    }

    // MARK: TableView Delegate / DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Page.cellIdentifier)!
        cell.contentView.subviews.forEach{ $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .canvas

        switch indexPath.row {
        case 0:
            cell.textLabel?.attributedText =
                .attributedString(with: "Normal", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField()
            textField.placeholder = "Standard Textfield with input"
            textField.text = "peter.pan@amboss.com"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        case 1:
            cell.textLabel?.attributedText =
                .attributedString(with: "Disabled", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField()
            textField.isEnabled = false
            textField.placeholder = "Disabled Textfield"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        case 2:
            cell.textLabel?.attributedText =
                .attributedString(with: "Error", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField(validator: EndlessStringValidator())
            textField.text = "Invalid input example - QA only"
            textField.isUserInteractionEnabled = false
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        case 3:
            cell.textLabel?.attributedText =
                .attributedString(with: "Validation", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField(validator: InputStringMinimumCountValidator())
            textField.placeholder = "Type to see validation"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            
        case 4:
            cell.textLabel?.attributedText =
                .attributedString(with: "Placeholder", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField()
            textField.placeholder = "Enter any text"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        case 5:
            cell.textLabel?.attributedText =
                .attributedString(with: "Secure", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField()
            textField.inputFieldType = .secureTextInput
            textField.placeholder = "Secure"
            textField.text = "123456789"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        case 6:
            cell.textLabel?.attributedText =
                .attributedString(with: "Search", style: .paragraphSmall, decorations: [.color(.textPrimary)])

            let textField = TextInputField()
            textField.inputFieldType = .search
            textField.placeholder = "Please enter your search term"
            cell.contentView.addSubview(textField)

            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 280).isActive = true
            textField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        default:
            return cell
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 75
    }
}

// MARK: - Validator
public class EndlessStringValidator: StringValidation {
    public init() {}

    public var errorMessage: String? {
        get {
            "You can't be right here!"
        }
    }

    public func validate(input: String?) -> Bool {
        (input ?? "").count > Int.max
    }
}

public class InputStringMinimumCountValidator: StringValidation {
    public init() {}

    public var errorMessage: String? {
        get {
            "You need to enter at least 5 characters!"
        }
    }

    public func validate(input: String?) -> Bool {
        (input ?? "").count > 4
    }
}
