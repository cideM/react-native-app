//
//  SupportService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 14.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// @mockable
protocol SupportApplicationService: ApplicationService, AnyObject {
    func showRequestViewController(on viewController: UIViewController, requestType: SupportRequestConfiguration)
    func showHelpCenterOverviewViewController(on viewController: UIViewController, requestType: SupportRequestConfiguration)
    var delegate: SupportApplicationServiceDelegate? { get set }
}
