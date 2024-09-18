//
//  Braze+Convenience.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 27.06.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import BrazeKit
import BrazeUI
import UIKit

extension Braze.ContentCard {

    var createdAt: TimeInterval {
        switch self {
        case .captionedImage(let captionedImage): return captionedImage.createdAt
        case .classic(let classic): return classic.createdAt
        case .classicImage(let classicImage): return classicImage.createdAt
        case .control(let control): return control.createdAt
        case .imageOnly(let imageOnly): return imageOnly.createdAt
        @unknown default: return 0
        }
    }

    var canBeDisplayed: Bool {
        (isMobile || isIOS) && !isAndroid
    }

    private var isMobile: Bool {
        let mobileKey = "mobile"
        let mobileValue = "true"
        return (self.extras[mobileKey] as? String) == mobileValue
    }

    private var isIOS: Bool {
        let osKey = "os"
        let iOSValue = "ios"
        return (self.extras[osKey] as? String) == iOSValue
    }

    private var isAndroid: Bool {
        let osKey = "os"
        let iOSValue = "android"
        return (self.extras[osKey] as? String) == iOSValue
    }

}
