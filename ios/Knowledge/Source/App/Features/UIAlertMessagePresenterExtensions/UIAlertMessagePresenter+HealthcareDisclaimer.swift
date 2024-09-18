//
//  PharmaDisclaimerDisplayer.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 05.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

extension UIAlertMessagePresenter {

    // This is used in various places hence the common logic was moved to this extension ...
    static func presentHealthcareDisclaimer(in viewController: UIViewController, didAgree completion: @escaping (Bool) -> Void) {

        // Does not really matter if true or false is returned from these closures
        // The return value is only important if MessageAction is used together with ErrorView
        let accept = MessageAction(title: L10n.Healthcare.Disclaimer.accept, style: .primary) { completion(true); return true }
        let reject = MessageAction(title: L10n.Healthcare.Disclaimer.reject, style: .normal) { completion(false); return true }

        UIAlertMessagePresenter(presentingViewController: viewController).present(
            title: L10n.Healthcare.Disclaimer.title,
            message: L10n.Healthcare.Disclaimer.content,
            actions: [accept, reject])
    }
}
