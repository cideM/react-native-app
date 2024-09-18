//
//  AppConfiguration+UserInterface.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AppConfiguration: UserInterfaceConfiguration {

    var languageCode: String {
        switch appVariant {
        case .knowledge: return "en"
        case .wissen: return "de"
        }
    }

    var popoverWidth: CGFloat {
        let bounds = UIScreen.main.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            return min(bounds.width, bounds.height)
        } else {
            return bounds.width
        }
    }
}
