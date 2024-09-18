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
import Networking

class ResetTermsCompliancePlugin: DebuggerPlugin {

    @Inject var userDataClient: UserDataClient

    let title = "Reset terms compliance"
    let description: String? = "Can be used to make the terms dialog show up again."

    func viewController() -> UIViewController {
        let errorViewController = UIViewController()
        let presenter = SubviewMessagePresenter(rootView: errorViewController.view)
        presenter.present(PresentableMessage(
            title: "In order to reset terms compliance please use the button below",
            description: "Background and foreground the app when done. Dialog should be presented ...",
            logLevel: .debug), actions: [
                MessageAction(title: "Reset", style: .primary) {
                    // This xid converts to zero, which means user has not accepted any terms yet ...
                    if let id = TermsIdentifier("Wf0PO2") {
                        self.userDataClient.acceptTermsAndConditions(id: id) { _ in
                            CATransaction.begin()
                            CATransaction.setCompletionBlock({
                                CATransaction.begin()
                                CATransaction.setCompletionBlock({
                                    // Background app ...
                                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                })
                                UIApplication.rootViewController?.presentedViewController?.dismiss(animated: true)
                                CATransaction.commit()
                            })
                            errorViewController.navigationController?.popToRootViewController(animated: true)
                            CATransaction.commit()
                        }
                    }
                    return false
                }
            ])
        errorViewController.title = "Force To Crash"
        return errorViewController
    }
}

#endif
