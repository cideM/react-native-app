//
//  LocalizationService.swift
//  Knowledge DE
//
//  Created by Manaf Alabd Alrahim on 09.06.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Localization
import Foundation
import UIKit

class LocalizationApplicationService: ApplicationService {

    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Localization.configure(
            config: Localization.Configuration(
                languageCode: AppConfiguration.shared.languageCode))
        return true
    }
}
