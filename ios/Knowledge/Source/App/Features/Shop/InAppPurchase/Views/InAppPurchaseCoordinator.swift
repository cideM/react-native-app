//
//  InAppPurchaseCoordinator.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 09.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// @mockable
protocol InAppPurchaseCoordinatorType {
    func manageInAppPurchaseSubscription()
    func goToSupport()
}

final class InAppPurchaseCoordinator: Coordinator, InAppPurchaseCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let supportApplicationService: SupportApplicationService
    private let supportRequestFactory: SupportRequestFactory
    private let isModal: Bool
    private let dismissCompletion: (() -> Void)?
    private let dismissModally: Bool

    init(_ navigationController: UINavigationController,
         supportApplicationService: SupportApplicationService = resolve(),
         supportRequestFactory: SupportRequestFactory = resolve(),
         isModal: Bool = false,
         dismissModally: Bool = false,
         dismissCompletion: (() -> Void)? = nil) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.supportApplicationService = supportApplicationService
        self.supportRequestFactory = supportRequestFactory
        self.isModal = isModal
        self.dismissModally = dismissModally
        self.dismissCompletion = dismissCompletion
    }

    func start(animated: Bool) {
        let inAppPurchaseStorePresenter = InAppPurchaseStorePresenter(inAppPurchaseApplicationService: resolve(), coordinator: self)
        let inAppPurchaseStoreViewController = InAppPurchaseStoreViewController(presenter: inAppPurchaseStorePresenter, isModal: isModal)
        if isModal {
            let navController = UINavigationController.withBarButton(rootViewController: inAppPurchaseStoreViewController, barButton: .close, closeCompletionClosure: self.dismissCompletion)
            navController.isModalInPresentation = true
            navigationController.present(navController)
        } else {
            navigationController.pushViewController(inAppPurchaseStoreViewController, animated: animated)
            if dismissModally {
                inAppPurchaseStoreViewController.navigationItem.leftBarButtonItem =
                UIBarButtonItem(image: Asset.closeButton.image, style: .plain) { [weak navigationController] _ in
                    navigationController?.navigationController.dismiss(animated: true, completion: self.dismissCompletion)
                }
            }
        }

    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: true) {
            self.dismissCompletion?()
        }
    }

    func manageInAppPurchaseSubscription() {
        let configuration: URLConfiguration = AppConfiguration.shared
        UIApplication.shared.open(configuration.inAppPurchaseManageSubscriptionURL)
    }

    func goToSupport() {
        supportApplicationService.showHelpCenterOverviewViewController(on: navigationController.navigationController, requestType: supportRequestFactory.standardSupportRequest())
    }
}
