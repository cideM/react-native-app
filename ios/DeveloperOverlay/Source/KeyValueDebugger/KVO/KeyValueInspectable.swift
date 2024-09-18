//
//  KeyValueInspectable.swift
//  DeveloperOverlay
//
//  Created by CSH on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public protocol KeyValueInspectable {
    var inspectableSection: KeyValueSection { get }
}
