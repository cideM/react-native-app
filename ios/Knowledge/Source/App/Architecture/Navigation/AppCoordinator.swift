//
//  AppCoordinator.swift
//  Knowledge
//
//  Created by CSH on 11.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Public properties -

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    // MARK: - Private properties -

    @Inject var tracker: TrackingType

    private let navigationController: SectionedNavigationController
    private let killSwitchCoordinator: KillSwitchCoordinatorType

    private let deepLinkService: DeepLinkServiceType
    private let shortcutsService: ShortcutsServiceType

    // MARK: - Lifecycle -

    init(_ navigationController: UINavigationController,
         deepLinkService: DeepLinkServiceType = resolve(), shortcutsService: ShortcutsServiceType = resolve()) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.deepLinkService = deepLinkService
        self.shortcutsService = shortcutsService
        self.killSwitchCoordinator = KillSwitchCoordinator(navigationController: navigationController, deepLinkService: deepLinkService)
    }

    // MARK: - Public functions -

    func start(animated: Bool) {
        // Since the loading of the login view controller might take a bit of time
        // (when user is not logged in), we show the launch screen to the navigation controller.
        // This way, user sees the launch screen instead of a black screen.
        if let launchScreenViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
            navigationController.pushViewController(launchScreenViewController, animated: animated)
        }
        navigationController.navigationController.setNavigationBarHidden(true, animated: animated)
        killSwitchCoordinator.start(animated: animated)
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
    }

}

// MARK: - User activity -

extension AppCoordinator {

    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return handleNonBrowsingWebUserActivityType(for: userActivity) }
        guard let webpageURL = userActivity.webpageURL else { return false }
        tracker.track(.appLifecycle(.openURL(webpageURL)))
        return deepLinkService.handleWebpageURL(webpageURL)
    }

    func handleDeeplink(_ url: URL) -> Bool {
        tracker.track(.appLifecycle(.openURL(url)))
        return deepLinkService.handleWebpageURL(url)
    }

    private func handleNonBrowsingWebUserActivityType(for userActivity: NSUserActivity) -> Bool {
        guard let deepLink = shortcutsService.deepLink(for: userActivity) else { return false }

        deepLinkService.handleDeepLink(deepLink)
        return true
    }
}
