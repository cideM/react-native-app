//
//  ArchiveCSSPlugin.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 01.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Common
import DIKit
import Domain
import UIKit
import DesignSystem

private let tag = "ArchiveCSSPlugin"

class ArchiveQAPlugin: DebuggerPlugin {

    static var urls: (branch: String, css: URL, js: URL)? {
        didSet {
            DispatchQueue.main.async {
                if urls != nil {
                    UIApplication.showInddicator(tag: tag)
                } else {
                    UIApplication.hideInddicator(tag: tag)
                }
            }
        }
    }

    let title = "QA CSS & JS: Library archive "
    let description: String? = "Uses library archive css & js from an S3 file (depending on branch name) instead of the local version. This is useful for testing css changes wihout going through the whole pod deployment procedure (which is very time consuming)"

    func viewController() -> UIViewController {
        ArchiveCSSViewController()
    }
}

class ArchiveCSSViewController: UIViewController {

    private lazy var container: LabeledWrapperView<TextInputField> = {
        let view = LabeledWrapperView<TextInputField>()
        view.title = "QA qranch name"
        view.inputTextField.autocorrectionType = .no
        view.inputTextField.autocapitalizationType = .none
        view.inputTextField.placeholder = "PHEX-..."
        view.inputTextField.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var button: TertiaryButton = {
        let view = TertiaryButton()
        view.isHidden = true
        view.title = "View ..."
        view.addTarget(self, action: #selector(presentCSS(sender:)), for: .touchUpInside)
        return view
    }()

    @objc func presentCSS(sender: AnyObject) {
        guard !css.isEmpty else { return }
        let viewController = ArchiveCSSPreviewViewController()
        viewController.textview.text = css
        navigationController?.pushViewController(viewController, animated: true)
    }

    private let callout: CalloutView = {
        let view = CalloutView()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var  stackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        let view = UIStackView(arrangedSubviews: [
            container,
            callout,
            button,
            spacer
        ])
        view.setCustomSpacing(16, after: container)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8

        return view
    }()

    private let queue = OperationQueue()

    private var css: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas

        view.addSubview(stackView)
        stackView.pin(to: view, insets: .init(horizontal: 16, vertical: 32))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = container.inputTextField.becomeFirstResponder()

        if let (branch, css, js) = ArchiveQAPlugin.urls {
            validate(.urls(branch: branch, css: css, js: js))
            container.inputTextField.text = branch
        } else {
            validate(.info("Using local css & js ..."))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = container.inputTextField.resignFirstResponder()
    }
}

extension ArchiveCSSViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {

            let status: Status
            let branch = text.replacingCharacters(in: textRange, with: string)
            if branch.isEmpty {
                status = .info("Using local css & js")
            } else {
                if let cssUrl = URL(string: "https://mobile-cdn.medicuja.de/\(branch)/mobile.css"),
                let jsUrl = URL(string: "https://mobile-cdn.medicuja.de/\(branch)/mobile.js") {
                    status = .urls(branch: branch, css: cssUrl, js: jsUrl)
                } else {
                    status = .error("URLs are invalid")
                }
            }

            validate(status)
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        validate(.info("Using local css & js ..."))
        return true
    }
}

private extension ArchiveCSSViewController {

    func validate(_ status: Status) {

        queue.addOperation { [weak self] in

            let title: String
            let description: String
            let type: CalloutView.CalloutType
            var cssString: String = ""

            ArchiveQAPlugin.urls = nil

            switch status {
            case .urls(let branch, let css, let js):
                do {
                    cssString = try String(contentsOf: css)
                    if cssString.isEmpty {
                        title = "Using local css & js ..."
                        description = "Enter branch name to use remote css & js"
                        type = .informational
                    } else {
                        title = "Using remote css & js for \(branch)..."
                        description = css.description
                        type = .success
                        ArchiveQAPlugin.urls = (branch: branch, css: css, js: js)
                    }
                } catch {
                    title = "Error"
                    description = "\(error)"
                    type = .error
                }
            case .info(let string):
                title = string
                description = "Enter branch name to use remote css & js"
                type = .informational

            case .error(let error):
                title = "Error"
                description = error
                type = .error
            }

            DispatchQueue.main.async { [weak self] in
                self?.callout.viewData = .init(title: title, description: description, calloutType: type)
                self?.button.isHidden = cssString.isEmpty
                self?.css = cssString
            }
        }
    }
}

private enum Status {
    case urls(branch: String, css: URL, js: URL)
    case info(String)
    case error(String)

    var description: String {
        switch self {
        case .urls(let branch, _, _): return "Loading from branch: \(branch)"
        case .info(let string): return string
        case .error(let string): return string
        }
    }
}

class ArchiveCSSPreviewViewController: UIViewController {

    let textview: UITextView = {
        let view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textview)
        textview.pin(to: view)
    }
}
#endif
