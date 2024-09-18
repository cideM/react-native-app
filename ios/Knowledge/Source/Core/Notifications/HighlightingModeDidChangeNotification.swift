//
//  HighlightingModeDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 26.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct HighlightingModeDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: Bool
    let newValue: Bool
}
