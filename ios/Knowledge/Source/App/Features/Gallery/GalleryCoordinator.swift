//
//  GalleryCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 20.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol GalleryCoordinatorType: Coordinator {
    func openURLExternally(_ url: URL)
    func navigate(to externalAddition: ExternalAdditionIdentifier, _ closeCompletionClosure: @escaping (() -> Void))
    func goToStore()
    func go(to galleryDeepLink: GalleryDeeplink)
    func go(to imageResource: ImageResourceIdentifier)

}

final class GalleryCoordinator: GalleryCoordinatorType {
    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let galleryRepository: GalleryRepositoryType
    private let tracker: GalleryAnalyticsTrackingProviderType
    private weak var galleryPresenter: GalleryPresenter?
    private let learningCardTitle: String?

    init(_ navigationController: UINavigationController,
         galleryRepository: GalleryRepositoryType,
         tracker: GalleryAnalyticsTrackingProviderType = resolve(),
         learningCardTitle: String?) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.galleryRepository = galleryRepository
        self.tracker = tracker
        self.learningCardTitle = learningCardTitle
    }

    func start(animated: Bool) {
        let galleryPresenter = GalleryPresenter(repository: galleryRepository, coordinator: self, tracker: tracker, learningCardTitle: learningCardTitle)
        let galleryViewController = GalleryViewController(presenter: galleryPresenter)
        navigationController.pushViewController(galleryViewController, animated: animated)
        self.galleryPresenter = galleryPresenter
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
    }

    func openURLExternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .external)
        webCoordinator.start(animated: true)
    }

    func navigate(to externalAddition: ExternalAdditionIdentifier, _ closeCompletionClosure: @escaping (() -> Void)) {

        let externalMediaNavigationController = UINavigationController()
        let externalMediaCoordinator = ExternalMediaCoordinator(externalMediaNavigationController,
                                                                dismissClosure: closeCompletionClosure,
                                                                galleryAnalyticsTrackingProvider: tracker)
        externalMediaCoordinator.start(animated: false)
        externalMediaCoordinator.openExternalAddition(with: externalAddition)
        navigationController.present(externalMediaNavigationController)

    }

    func goToStore() {
        let coordinator = InAppPurchaseCoordinator(self.rootNavigationController)
        coordinator.start(animated: true)
    }

    func go(to galleryDeepLink: GalleryDeeplink) {
        galleryPresenter?.go(to: galleryDeepLink)
    }

    func go(to imageResource: ImageResourceIdentifier) {
        galleryPresenter?.go(to: imageResource)
    }
}
