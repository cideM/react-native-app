//
//  ApplicationService.swift
//  Knowledge
//
//  Created by AMBOSS  VSS on 10.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

// @protocol(ApplicationService) replaces "UIApplication" with "UIApplicationType" to aid testabiilty
/// @mockable
protocol UIApplicationType {
    var keyWindow: UIWindow? { get }
    var applicationState: UIApplication.State { get }

    func setMinimumBackgroundFetchInterval(_ minimumBackgroundFetchInterval: TimeInterval)
}

extension UIApplication: UIApplicationType {}

/// Interface for UIApplicationDelegate methods
protocol ApplicationService {
    func application(_ application: UIApplicationType, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func applicationWillResignActive(_ application: UIApplicationType)
    func applicationDidEnterBackground(_ application: UIApplicationType)
    func applicationWillEnterForeground(_ application: UIApplicationType)
    func applicationDidBecomeActive(_ application: UIApplicationType)
    func applicationWillTerminate(_ application: UIApplicationType)
    func application(_ application: UIApplicationType, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
    func application(_ application: UIApplicationType, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

extension ApplicationService {
    func application(_ application: UIApplicationType, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool { true }
    func applicationWillResignActive(_ application: UIApplicationType) {}
    func applicationDidEnterBackground(_ application: UIApplicationType) {}
    func applicationWillEnterForeground(_ application: UIApplicationType) {}
    func applicationDidBecomeActive(_ application: UIApplicationType) {}
    func applicationWillTerminate(_ application: UIApplicationType) {}
    func application(_ application: UIApplicationType, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {}
    func application(_ application: UIApplicationType, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) { completionHandler(.noData) }
}
