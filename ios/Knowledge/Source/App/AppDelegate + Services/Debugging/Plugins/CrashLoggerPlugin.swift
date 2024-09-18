//
//  CrashLoggerPlugin.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 17.12.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Common
import DIKit
import Domain
import UIKit

class CrashLoggerPlugin: DebuggerPlugin {
    let title = "Error logging"
    let description: String? = "Can be used to send a simulated error to crashlytics"

    func viewController() -> UIViewController {
        LoggerPluginViewController()
    }
}

extension CrashLoggerPlugin {

    class LoggerPluginViewController: UIViewController {

        @Inject var crashlyticsLogger: CrashlyticsMonitor

        lazy var errors: [Error] = {
            makeErrors()
        }()

        lazy var statusLabel: UILabel = {
            label(title: "No error sent yet!", textColor: .red, textAlignment: .center)
        }()

        lazy var errorDomainField: UITextField = {
            textField(text: "TestErrorDomain")
        }()

        lazy var errorInfoKeyField: UITextField = {
            textField(text: String.random(length: 12))
        }()

        lazy var errorInfoValueField: UITextField = {
            textField(text: String(describing: Int.random(in: 1000...9999)))
        }()

        lazy var sendErrorButton: UIButton = {
            let button = button(with: "Send error to crashlytics!")
            button.isEnabled = false
            return button
        }()

        lazy var errorMenu: UIButton = {
            let button = button(with: "Select error type")
            if #available(iOS 15, *) {
                button.menu = UIMenu(title: "Erorrs", children: errors.map { error in
                    let title = String(describing: type(of: error))
                    return UIAction(title: title) {  [weak self] _ in
                        guard let self = self else { return }
                        let context = self.contextToSend ?? .none
                        let nsError = self.crashlyticsLogger.crashlyticsNSError(object: error, context: context, file: "", function: "", line: 0)
                        button.setTitle(nsError.domain, for: .normal)
                        self.errorToSend = error
                        self.sendErrorButton.isEnabled = self.errorToSend != nil && self.contextToSend != nil
                    }
                })
                button.showsMenuAsPrimaryAction = true
            }
            return button
        }()

        lazy var errorContextMenu: UIButton = {
            let button = button(with: "Select error context")
            if #available(iOS 15, *) {
                button.menu = UIMenu(title: "Context", children: MonitorContext.allCases.map { context in
                    let title = String(describing: context)
                    return UIAction(title: title) {  [weak self] _ in
                        button.setTitle(title, for: .normal)
                        self?.contextToSend = context
                        self?.sendErrorButton.isEnabled = self?.errorToSend != nil && self?.contextToSend != nil
                    }
                })
                button.showsMenuAsPrimaryAction = true
            }
            return button
        }()

        var errorToSend: Error?
        var contextToSend: MonitorContext?

        override func loadView() {

            view = UIView()
            view.backgroundColor = .white

            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.spacing = 4
            stackView.axis = .vertical
            view.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
            ])

            [
                spacer(color: .clear),
                label(title: "Configure the NSError payload here. All errors sent from here will have error code >99< in order to find them easier in the crashlytics console."),
                spacer(color: .clear),

                label(title: "NSError domain:"),
                errorDomainField,
                spacer(),

                label(title: "NSError userInfo key:"),
                errorInfoKeyField,
                spacer(),

                label(title: "NSError userInfo value:"),
                errorInfoValueField,
                spacer(color: .clear, height: 14),

                label(title: "Configure the erorr type here. Only a subset of errors is available in order to keep things simple."),
                spacer(color: .clear, height: 4),
                spacer(),

                errorMenu,
                spacer(color: .clear, height: 4),
                errorContextMenu,
                spacer(),

                UIView(), // -> Push everything else to the bottom of the view

                sendErrorButton,
                spacer(color: .clear, height: 4),

                label(title: "Errors in DEBUG and QA builds may only be logged to Crashlytics from this screen. Crashlytics is otherwise disabled in these builds.", textColor: .darkGray, textAlignment: .center),

                spacer(color: .clear, height: 4),
                statusLabel

            ].forEach {
                stackView.addArrangedSubview($0)
            }
        }

        @objc func sendError(sender: UIButton) {
            guard let error = errorToSend, let context = contextToSend else {
                sendErrorButton.isEnabled = false
                return
            }

            statusLabel.text = "Error sent: \(String(describing: type(of: error)))"
            statusLabel.textColor = .darkGray
            crashlyticsLogger.log(error, with: .error, context: context, file: #file, function: #function, line: #line)
        }
    }
}

extension CrashLoggerPlugin.LoggerPluginViewController {

    private func label(title: String, textColor: UIColor = UILabel().textColor, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.text = title
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    private func textField(text: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.text = text
        return textField
    }

    private func spacer(color: UIColor = .lightGray.withAlphaComponent(0.25), height: CGFloat = 1) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        spacer.addConstraint(heightConstraint)
        spacer.backgroundColor = color
        return spacer
    }

    private func button(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(sendError(sender:)), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }

    private func makeErrors() -> [Error] {
        var userInfo = [String: String]()
        if let key = errorInfoKeyField.text, let value = errorInfoValueField.text {
            userInfo[key] = value
        }
        let nserror = NSError(domain: errorDomainField.text ?? "", code: 99, userInfo: userInfo)

        return [
            UnzipperError.other(nserror),
            RemoteConfigSynchError.unknownError(nserror),
            InAppPurchaseApplicationServiceError.other(nserror),
            SearchError.offlinePharmaDatabaseError(nserror),
            TagSynchroniser.TagSynchroniserError.downloadFailed(nserror)
        ]
    }
}

extension CrashLoggerPlugin.LoggerPluginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // unused:ignore textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        errors = makeErrors()
    }
}

fileprivate extension String {

    // Taken from here: https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        // swiftlint:disable:next force_unwrapping
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

#endif
