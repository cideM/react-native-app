//
//  DSMainViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 25.07.23.
//

import UIKit
import DesignSystem

class MainCatalogViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            UINavigationController(rootViewController: FoundationViewController()),
            UINavigationController(rootViewController: ComponentsViewController()),
            UINavigationController(rootViewController: PageViewController()),
        ]

        applyUITabBarAppearance()
        applyUINavigationBarAppearance()
    }

    private func applyUITabBarAppearance() {
        if #available(iOS 15, *) {
            let standard = UITabBarAppearance()
            standard.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = standard
            UITabBar.appearance().scrollEdgeAppearance = standard
        }
        UITabBar.appearance().tintColor = .textAccent
    }


    private func applyUINavigationBarAppearance() {
        UINavigationBar.appearance().titleTextAttributes = .attributes(style: .paragraph)
        UINavigationBar.appearance().tintColor = .textPrimary
    }
}
