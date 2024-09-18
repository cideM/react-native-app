//
//  UIAlertMessagePresenter.swift
//  Knowledge DE
//
//  Created by Silvio Bulla on 17.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// This class is responsible for presenting a `UIAlertController` for every `PresentableMessage`.
public class UIAlertMessagePresenter: MessagePresenter {

    let presentingViewController: UIViewController

    /// Initializes the `UIAlertMessagePresenter` with an instance of `UIViewController`.
    ///
    /// - Parameters:
    ///   - presentingViewController: The view controller that is going to be responsible for the presentation of the `UIAlertViewController`.
    public init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    public func present(title: String, message: String? = nil, actions: [MessageAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { messageAction in
            let alertAction = UIAlertAction(title: messageAction.title, style: .default) { _ in
                messageAction.execute()
            }
            alert.addAction(alertAction)
            if messageAction.style == .primary {
                alert.preferredAction = alertAction
            }
        }
        presentingViewController.present(alert, animated: true)
    }

    public func present(_ message: PresentableMessageType, actions: [MessageAction]) {
        let alert = UIAlertController(title: message.title, message: message.body, preferredStyle: .alert)

        // Creating a `UIAlertAction` for every `MessageAction`.
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                action.execute()
            }
            alert.addAction(alertAction)
            // Our `UIAlertController` can have only one primary button.
            if action.style == .primary {
                alert.preferredAction = alertAction
            }
        }

        presentingViewController.present(alert, animated: true)
    }
}
