//
//  UserInterfaceStyleChangedNotification.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 13.11.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation
import UIKit

struct UserInterfaceStyleChangedNotification: AutoNotificationRepresentable {
    let style: UIUserInterfaceStyle
}
