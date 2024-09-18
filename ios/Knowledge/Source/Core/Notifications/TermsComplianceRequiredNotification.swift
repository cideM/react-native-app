//
//  TermsDidUpdateNotification.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.04.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Domain

struct TermsComplianceRequiredNotification: AutoNotificationRepresentable {
    var oldValue: Bool?
    var newValue: Bool
}
