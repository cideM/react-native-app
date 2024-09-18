//
//  ExternalMediaCoordinator.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 04.10.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol ExternalMediaCoordinatorType: Coordinator {
    func openExternalAddition(with identifier: ExternalAdditionIdentifier)
    func openVideoWithoutCheckingForPermissions(with url: URL)
    func goToStore()
}

final class ExternalMediaCoordinator: ExternalMediaCoordinatorType {

    var rootNavigationController: UINavigationController
    private let externalMediaRepository: ExternalMediaRepositoryType
    private let accessRepository: AccessRepositoryType
    private let galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderType
    private let dismissClosure: (() -> Void)?
    private weak var presenter: ExternalMediaPresenterType?

    init(_ navigationController: UINavigationController,
         dismissClosure: (() -> Void)? = nil,
         externalMediaRepository: ExternalMediaRepositoryType = resolve(),
         accessRepository: AccessRepositoryType = resolve(),
         galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderType = resolve()) {

        self.rootNavigationController = navigationController
        self.dismissClosure = dismissClosure
        self.externalMediaRepository = externalMediaRepository
        self.accessRepository = accessRepository

        // Note on Tracking provider:
        //   - LearningCardTracker is injected here  as GalleryAnalyticsTrackingProviderType
        //     when the flow is initiated from articles
        //   - GalleryAnalyticsTrackingProviderType is resolved to GalleryAnalyticsTrackingProvider
        //     here when the flow is initiated from search
        // The main difference is that the former injects articleId in tracking events, while the latter does not.
        self.galleryAnalyticsTrackingProvider = galleryAnalyticsTrackingProvider
    }

    func start(animated: Bool) {

        let presenter = ExternalMediaPresenter(externalMediaRepository: externalMediaRepository, accessRepository: accessRepository, coordinator: self, galleryAnalyticsTrackingProvider: galleryAnalyticsTrackingProvider)
        self.presenter = presenter
        let viewController = WebViewController(presenter: presenter)

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done) { [weak self] _ in
            self?.stop(animated: true)
            self?.presenter?.dismissExternalAddition()
            self?.dismissClosure?()
        }
        viewController.navigationItem.rightBarButtonItem = doneBarButtonItem
        rootNavigationController.modalPresentationStyle = .fullScreen
        rootNavigationController.pushViewController(viewController, animated: animated)
    }

    func stop(animated: Bool) {
        rootNavigationController.dismiss(animated: animated)
    }

    func openExternalAddition(with identifier: ExternalAdditionIdentifier) {
        presenter?.fetchAndShowExternalAddition(with: identifier)
    }

    func openVideoWithoutCheckingForPermissions(with url: URL) {
        presenter?.showExternalAddition(with: url, and: .video)
    }

    func goToStore() {
        let coordinator = InAppPurchaseCoordinator(self.rootNavigationController)
        coordinator.start(animated: true)
    }
}
