//
//  AppNavigationController.swift
//  Knowledge
//
//  Created by CSH on 04.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class AppNavigationController: UINavigationController {

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if let event = event, event.subtype == .motionShake {
            // This notification is used to present the developer overlay if the device is shaken
            NotificationCenter.default.post(ShakeMotionDidEndNotification(), sender: nil)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? [.portrait, .landscape]
    }
}
