//
//  AppDelegate.swift
//  Knowledge
//
//  Created by CSH on 02.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Domain
import Firebase
import UIKit

class AppDelegate: UIResponder {

    var window: UIWindow?
    lazy var appCoordinator = AppCoordinator(AppNavigationController())

    /// When a background download is completed while the app is in suspended state the delegate method `application(_:, handleEventsForBackgroundURLSession, completionHandler:)` is called.
    /// When it is called, we need to store the completion for later usage.
    private(set) var backgroundCompletionHandler: (() -> Void)?

    @LazyInject private var monitor: Monitoring
    @LazyInject private var libraryUpdateApplicationService: LibraryUpdateApplicationServiceType
    @LazyInject private var supportApplicationService: SupportApplicationService
    @LazyInject private var inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType
    @LazyInject private var consentApplicationService: ConsentApplicationServiceType
    @LazyInject private var attributionTrackingApplicationService: AttributionTrackingApplicationServiceType
    @LazyInject private var brazeApplicationService: BrazeApplicationServiceType
    @LazyInject private var appearanceApplicationService: AppearanceApplicationServiceType

    private lazy var applicationServices: [ApplicationService] = {
        var services = [
            DebuggerApplicationService(),
            TrackingClientApplicationService(),
            LocalizationApplicationService(),
            appearanceApplicationService,
            libraryUpdateApplicationService,
            SynchronizationApplicationService(synchronizers: [
                UserDataSynchronizer(),
                FeedbackSynchronizer(),
                TagSynchroniser(),
                ExtensionSynchroniser(),
                SharedExtensionSynchronizer(),
                AccessSynchronizer(),
                QBankAnswerSynchronizer(),
                KillSwitchSynchronizer(),
                ReadingsSynchronizer(),
                RemoteConfigSynchronizer()
            ]),
            supportApplicationService,
            inAppPurchaseApplicationService,
            consentApplicationService,
            attributionTrackingApplicationService,
            brazeApplicationService
        ]

        let pharmaService: PharmaDatabaseApplicationServiceType? = resolve()
        if let service = pharmaService {
            services.append(service)
        }

        return services
    }()

    override init() {

        // This MUST run as the very first thing because:
        // * The DeeplinkService requires firebases remote config
        // * The remote config only works if "FirebaseApp.configure()" was executed before
        // * The Deeplink service is actually already initialized in the next line
        // Hence: This is the only place where we could put this. Sorry.
        FirebaseApp.configure()

        super.init()
        DependencyContainer.defined(by: DependencyContainer.derive(from: [.storage, .basic, .network, .library, .repository, .applicationService, .tracking, .deepLinkService, .builder, .pharmaDatabase]))
    }
}

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        applicationServices.allSatisfy { service in
            service.application(application, willFinishLaunchingWithOptions: launchOptions)
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appCoordinator.rootNavigationController
        window?.makeKeyAndVisible()
        appCoordinator.start(animated: false)

        excludeDocumentDirectoryFromiCloudBackup()

        return applicationServices.allSatisfy { service in
            service.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        applicationServices.forEach { $0.applicationWillResignActive(application) }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        applicationServices.forEach { $0.applicationDidEnterBackground(application) }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        applicationServices.forEach { $0.applicationWillEnterForeground(application) }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        applicationServices.forEach { $0.applicationDidBecomeActive(application) }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        applicationServices.forEach { $0.applicationWillTerminate(application) }
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        applicationServices.forEach { $0.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler) }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dispatchGroup = DispatchGroup()
        var backgroundFetchResults: [UIBackgroundFetchResult] = []

        for backgroundFetchService in applicationServices {
            dispatchGroup.enter()
            backgroundFetchService.application(application) { backgroundFetchResult in
                backgroundFetchResults.append(backgroundFetchResult)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if backgroundFetchResults.contains(.newData) {
                completionHandler(.newData)
            } else if backgroundFetchResults.contains(.noData) {
                completionHandler(.noData)
            } else {
                completionHandler(.failed)
            }
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        appCoordinator.handleUserActivity(userActivity)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        appCoordinator.handleDeeplink(url)
    }
}

extension UIApplication {

    @available(iOS,
               deprecated: 16,
               message: "Don't use the AppDelegate to get any kind of dependency but rather use dependency injection.")
    var appDelegate: AppDelegate? {
        delegate as? AppDelegate
    }
}

private extension AppDelegate {
    /// This method excludes the whole document directory from iCloud backup.
    /// Our application stores libraries and other data inside document directory. We dont' want this data to be included in iCloud backups as it needs a big amount of storage.
    /// This method makes sure no data from the document directory is going to be included in iCloud backup.
    func excludeDocumentDirectoryFromiCloudBackup() {
        guard var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
            try documentsDirectory.setResourceValues(values)
        } catch {
            monitor.warning("Could not exclude documents directory from backups", context: .system)
        }
    }
}
