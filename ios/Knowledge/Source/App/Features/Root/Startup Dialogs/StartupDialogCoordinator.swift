//
//  StarupDialogCoordinator.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 11.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit
/// @mockable
protocol StartupDialogCoordinatorType: Coordinator {
    func showStore(completion: @escaping () -> Void)
}

protocol StartupDialogCoordinatorDelegate: AnyObject {
    func didFinishStartupDialogs()
}

final class StartupDialogCoordinator: StartupDialogCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private var presenter: StartupDialogPresenterType?
    private weak var delegate: StartupDialogCoordinatorDelegate?

    init(_ navigationController: UINavigationController, delegate: StartupDialogCoordinatorDelegate?) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.delegate = delegate
    }

    func start(animated: Bool) {
        self.presenter = StartupDialogPresenter(coordinator: self)
        presenter?.showFirstDialog()
    }

    func stop(animated: Bool) {
        self.navigationController.dismissAndPopAll(animated: true) {
            self.delegate?.didFinishStartupDialogs()
        }
    }

    func showStore(completion: @escaping () -> Void) {
        let storeCoordinator = InAppPurchaseCoordinator(self.rootNavigationController, isModal: true, dismissCompletion: completion)
        storeCoordinator.start(animated: true)
    }
}
