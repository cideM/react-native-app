//
//  SearchCoordinator.swift
//  Knowledge
//
//  Created by Silvio Bulla on 24.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import IntentsUI
import UIKit

/// @mockable
protocol SearchCoordinatorType: Coordinator {
    func navigate(to searchDeepLink: SearchDeeplink)
    func navigate(to uncommitedSearchDeepLink: UncommitedSearchDeeplink)
    func navigate(to learningCard: LearningCardDeeplink)
    func navigate(to substance: SubstanceIdentifier, drug: DrugIdentifier?)
    func navigate(to monographDeeplink: MonographDeeplink)
    func navigate(to imageResourceIdentifier: ImageResourceIdentifier)
    func navigate(to externalAddition: ExternalAdditionIdentifier)
    func navigateToAddVoiceSearchShortcut()
    func openURLInternally(_ url: URL)
    func openURLExternally(_ url: URL)
}

final class SearchCoordinator: NSObject, SearchCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let shortcutsService: ShortcutsServiceType
    private weak var searchDelegate: SearchDelegate?
    private weak var presenter: SearchPresenter?

    init(_ navigationController: UINavigationController, shortcutsService: ShortcutsServiceType = resolve(), searchDelegate: SearchDelegate) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.shortcutsService = shortcutsService
        self.searchDelegate = searchDelegate
    }

    func start(animated: Bool) {
        let presenter = SearchPresenter(coordinator: self)
        let searchView = SearchViewController(presenter: presenter)
        searchView.definesPresentationContext = true
        navigationController.pushViewController(searchView, animated: animated)
        self.presenter = presenter
    }

    func stop(animated: Bool) {
        stop(animated: animated, completion: nil)
    }

    func navigate(to learningCard: LearningCardDeeplink) {
        self.searchDelegate?.navigate(to: learningCard)
    }

    func navigate(to substance: SubstanceIdentifier, drug: DrugIdentifier?) {
        self.searchDelegate?.navigate(to: PharmaCardDeeplink(substance: substance, drug: drug, document: nil))
    }

    func navigate(to searchDeepLink: SearchDeeplink) {
         self.presenter?.navigate(to: searchDeepLink)
    }

    func navigate(to uncommitedSearchDeepLink: UncommitedSearchDeeplink) {
        self.presenter?.navigate(to: uncommitedSearchDeepLink)
    }

    func navigate(to monographDeeplink: MonographDeeplink) {
        self.searchDelegate?.navigate(to: monographDeeplink)
    }

    func navigate(to imageResourceIdentifier: ImageResourceIdentifier) {
        let galleryNavigationController = UINavigationController()
        galleryNavigationController.modalPresentationStyle = .fullScreen
        let galleryCoordinator = GalleryCoordinator(galleryNavigationController,
                                                    galleryRepository: GalleryRepository(),
                                                    learningCardTitle: nil)
        galleryCoordinator.start(animated: true)
        galleryCoordinator.go(to: imageResourceIdentifier)
        navigationController.present(galleryNavigationController, animated: true)

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done) { [weak self] _ in
            self?.navigationController.dismissPresented(animated: true) {
                galleryCoordinator.stop(animated: false)
            }
        }
        galleryNavigationController.topViewController?.navigationItem.leftBarButtonItem = doneBarButtonItem
    }

    func navigateToAddVoiceSearchShortcut() {
        let addVoiceSearchShortcutViewController = shortcutsService.newAddVoiceShortcutViewController(for: .search, delegate: self)
        navigationController.present(addVoiceSearchShortcutViewController)
    }

    private func stop(animated: Bool, completion: (() -> Void)? = nil) {
        searchDelegate?.dismissSearchView { [weak self] in
            completion?()
            self?.navigationController.dismissAndPopAll()
        }
    }

    func openURLInternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .internal(modalPresentationStyle: .fullScreen))
        webCoordinator.start(animated: true)
    }

    func openURLExternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .external)
        webCoordinator.start(animated: true)
    }

    func navigate(to externalAddition: ExternalAdditionIdentifier) {

        let externalMediaNavigationController = UINavigationController()
        let externalMediaCoordinator = ExternalMediaCoordinator(externalMediaNavigationController)
        externalMediaCoordinator.start(animated: false)
        externalMediaCoordinator.openExternalAddition(with: externalAddition)

        navigationController.present(externalMediaNavigationController)

    }
}

extension SearchCoordinator: INUIAddVoiceShortcutViewControllerDelegate {
    // unused:ignore addVoiceShortcutViewControllerDidCancel
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        navigationController.dismissPresented()
    }

    // unused:ignore addVoiceShortcutViewController
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        navigationController.dismissPresented()
    }
}
