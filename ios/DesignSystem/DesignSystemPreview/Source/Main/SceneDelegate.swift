//
//  SceneDelegate.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let storyBoardMode = false

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if storyBoardMode {
            guard let _ = (scene as? UIWindowScene) else { return }
        }
        else {
            guard let winScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: winScene)
            window?.rootViewController = MainCatalogViewController()
            window?.makeKeyAndVisible()

            addSplashScreenViewcontroller()
        }
    }

    private let splashScreenViewController = SplashScreenViewController()
    private func addSplashScreenViewcontroller() {
        window?.addSubview(splashScreenViewController.view)
    }
}
