//
//  ForcedCrashPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import Common
import DIKit
import Domain
import UIKit

class ForcedCrashPlugin: DebuggerPlugin {
    let title = "Forced Crash"
    let description: String? = "Can be used to crash the application and test crashreporting."

    func viewController() -> UIViewController {
        let errorViewController = UIViewController()
        let presenter = SubviewMessagePresenter(rootView: errorViewController.view)
        presenter.present(PresentableMessage(title: "To have a Crash", description: "Please use the button below", logLevel: .debug), actions: [
            MessageAction(title: "Crash", style: .primary) {
                fatalError("Force crash button tapped")
            }
        ])
        errorViewController.title = "Force To Crash"
        return errorViewController
    }
}
#endif
