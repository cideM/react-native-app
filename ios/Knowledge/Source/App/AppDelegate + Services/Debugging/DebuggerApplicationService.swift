//
//  DebuggerApplicationService.swift
//  Knowledge
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import AcknowList
import Common
import DeveloperOverlay
import Domain
import Networking
import UIKit

#if Debug || QA

internal class DebuggerApplicationService: ApplicationService {

    private let plugins: [DebuggerPlugin] = [
        CauliPlugin(),
        ForcedCrashPlugin(),
        ResetTermsCompliancePlugin(),
        CrashLoggerPlugin(),
        FeatureFlagPlugin(),
        PharmaDatabaseMetadataDebugger(),
        UserdataPlugin(),
        UserDefaultsPlugin(),
        LibraryDebuggingPlugin(),
        FilesDebuggerPlugin(path: FilesDebuggerPlugin.appSandboxDirectory),
        FilesDebuggerPlugin(path: FilesDebuggerPlugin.logsDirectory, title: "Log Files", description: nil),
        ThemeDebugger(theme: ThemeManager.currentTheme),
        ArchiveQAPlugin(),
        PocketGuidesURLPlugin()
    ]

    private var shakeObserver: NSObjectProtocol?
    private weak var shownDebuggerViewController: UIViewController?

    init() {
        shakeObserver = NotificationCenter.default.observe(for: ShakeMotionDidEndNotification.self, object: nil, queue: .main) { [weak self] _ in
            self?.didObserveShakeGesture()
        }
    }

    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    private func didObserveShakeGesture() {
        guard let rootViewController = visibleViewController() else { return }
        if let shownDebuggerViewController = shownDebuggerViewController {
            shownDebuggerViewController.dismiss(animated: true, completion: nil)
            self.shownDebuggerViewController = nil
        } else {
            let debuggerViewController = self.debuggerViewController()
            debuggerViewController.modalPresentationStyle = .overFullScreen
            rootViewController.present(debuggerViewController, animated: true, completion: nil)
            shownDebuggerViewController = debuggerViewController
        }
    }

    private func debuggerViewController() -> UIViewController {
        let pluginListViewController = PluginListTableViewController(plugins: plugins)
        pluginListViewController.title = "Debugger"
        return UINavigationController.withBarButton(rootViewController: pluginListViewController)
    }

    private func visibleViewController() -> UIViewController? {
        guard var viewController = UIApplication.rootViewController else { return nil }
        while let presented = viewController.presentedViewController {
            viewController = presented
        }
        return viewController
    }
}

#else

internal class DebuggerApplicationService: ApplicationService {
    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }
}

#endif
