//
//  PocketGuidesURLPlugin.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 30.08.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

#if DEBUG || QA
import Foundation
import UIKit
import Common

class PocketGuidesURLPlugin: DebuggerPlugin {
    var title: String {
        "Pocket Guides URL Plugin"
    }

    static var urlValue: String? {
        get {
            UserDefaults.standard.string(forKey: "PocketGuidesURLPlugin.urlValue")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "PocketGuidesURLPlugin.urlValue")
        }
    }

    var description: String?

    func viewController() -> UIViewController {
        PocketGuidesURLPluginViewController(value: Self.urlValue)
    }

}

class PocketGuidesURLPluginViewController: UIViewController {

    private var textField: UITextField?

    private let value: String?

    init(value: String?) {
        self.value = value
        super.init(nibName: nil, bundle: nil)
        self.title = "Pocket Guides URL"
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let text = textField?.text, !text.isEmpty {
            PocketGuidesURLPlugin.urlValue = text
        } else {
            PocketGuidesURLPlugin.urlValue = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pocket Guides URL"
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let textField = UITextField()
        self.textField = textField
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = value
        textField.placeholder = "Pocket guides url"
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let explanationLabel = UILabel()
        explanationLabel.text = "The full url to replace the pocket guides initail url with"
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
