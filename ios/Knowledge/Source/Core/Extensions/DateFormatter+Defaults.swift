//
//  DateFormatter+Defaults.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 25.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// The default date formatter to be used app-wide to display dates without time.
    static let defaultDisplayDateOnlyDateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        let template = "ddMMMyyyy"

        switch AppConfiguration.shared.appVariant {
        case .wissen: dateFormatter.locale = Locale(identifier: "de")
        case .knowledge: dateFormatter.locale = Locale(identifier: "en-us")
        }

        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter
    }()
}
