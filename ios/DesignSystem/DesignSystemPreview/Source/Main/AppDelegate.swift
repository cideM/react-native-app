//
//  AppDelegate.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import UIKit
import DesignSystem

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setup()
       return true
    }

    // MARK: - DS Setup
    private func setup() {
        DesignSystem.initialize()
    }
}
