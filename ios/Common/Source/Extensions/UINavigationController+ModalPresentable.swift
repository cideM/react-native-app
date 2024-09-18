//
//  UINavigationController+ModalPresentable.swift
//  Common
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension UINavigationController {
    static func withBarButton(rootViewController: UIViewController, barButton: UIBarButtonItem.SystemItem = .done, closeCompletionClosure: (() -> Void)? = nil) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: barButton) { [weak navigationController] _ in
            navigationController?.dismiss(animated: true, completion: closeCompletionClosure)
        }
        return navigationController
    }
}
