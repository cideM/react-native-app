//
//  CauliBranchSelectionFloret.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 07.10.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Cauliframework
import Common

import UIKit

class CauliBranchSelectionFloret: InterceptingFloret, DisplayingFloret {
    let name = "Branch Selection"
    var enabled: Bool {
        get {
            Self.enabled
        }
        set {
            Self.enabled = newValue
        }
    }
    static var enabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "CauliBranchSelectionFloret.enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CauliBranchSelectionFloret.enabled")
        }
    }
    static var branchName: String {
        get {
            UserDefaults.standard.string(forKey: "CauliBranchSelectionFloret.branchName") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CauliBranchSelectionFloret.branchName")
        }
    }

    func willRequest(_ record: Record, modificationCompletionHandler completionHandler: @escaping (Record) -> Void) {
        let restRewritten = rewriteRest(record: record, branch: Self.branchName)
        let graphQlRewritten = rewriteGraphQl(record: restRewritten, branch: Self.branchName)
        completionHandler(graphQlRewritten)
    }

    func didRespond(_ record: Record, modificationCompletionHandler completionHandler: @escaping (Record) -> Void) {
        completionHandler(record)
    }

    func viewController(_ cauli: Cauli) -> UIViewController {
        CauliBranchSelectionViewController(key: "Branch Name", value: Self.branchName) { [weak self] newValue in
            Self.branchName = newValue
        }
    }

    private func rewriteRest(record: Record, branch: String) -> Record {
        let find = AppConfiguration.shared.restBaseURL.absoluteString
        let replace: String
        switch AppConfiguration.shared.appVariant {
        case .wissen:
            replace = "https://\(branch).vesikel.de.qa.medicuja.de/"
        case .knowledge:
            replace = "https://\(branch).vesikel.us.qa.medicuja.de/"
        }

        return findAndReplaceRequestUrl(record: record, find: find, replace: replace)
    }

    private func rewriteGraphQl(record: Record, branch: String) -> Record {
        let find = AppConfiguration.shared.graphQLURL.absoluteString
        let replace: String
        switch AppConfiguration.shared.appVariant {
        case .wissen:
            replace = "https://\(branch).graphql-gateway.de.qa.medicuja.de/graphql"
        case .knowledge:
            replace = "https://\(branch).graphql-gateway.us.qa.medicuja.de/graphql"
        }

        return findAndReplaceRequestUrl(record: record, find: find, replace: replace)
    }

    private func findAndReplaceRequestUrl(record: Record, find: String, replace: String) -> Record {
        guard let oldValue = record.designatedRequest.url else { return record }
        var newRecord = record
        var request = newRecord.designatedRequest
        request.url = URL(string: oldValue.absoluteString.replacingOccurrences(of: find, with: replace))
        newRecord.designatedRequest = request
        return newRecord
    }
}

class CauliBranchSelectionViewController: UIViewController {

    private var textField: UITextField?

    private let value: String?
    private let onChange: (String) -> Void

    init(key: String, value: String?, onChange: @escaping (String) -> Void) {
        self.value = value
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
        self.title = key
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let textField = textField else { return }
        onChange(textField.text ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Branch"
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let textField = UITextField()
        self.textField = textField
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = value
        textField.placeholder = "branch"
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let explanationLabel = UILabel()
        explanationLabel.text = "The name of the branch. Remember to also enable the plugin after setting the branch."
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(explanationLabel)
        view.addSubview(stack)
        stack.constrainEdges(to: view.layoutMarginsGuide)
    }
}

#endif
