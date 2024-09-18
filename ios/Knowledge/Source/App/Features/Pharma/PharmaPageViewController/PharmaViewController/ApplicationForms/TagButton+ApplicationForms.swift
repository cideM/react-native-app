//
//  TagButton+ApplicationForms.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import DesignSystem

extension TagButton {

    struct ViewData {
        let count: Int
        let applicationForm: ApplicationForm
    }

    static func styled(for applicationForm: ApplicationForm) -> TagButton {
        let button = TagButton()
        button.setBackgroundColor(.clear, for: .normal)
        button.setBorderColor(.borderSecondary, for: .normal)
        button.setBackgroundColor(.backgroundTransparentSelected, for: .selected)
        button.setBorderColor(.backgroundTransparentSelected, for: .selected)
        return button
    }

    func setTitle(with data: ViewData) {
        let name = data.applicationForm.name
        let normalTitle: NSMutableAttributedString = .attributedString(with: name, style: .paragraphSmallBold, decorations: [.color(.textSecondary)])
        let selectedTitle: NSMutableAttributedString = .attributedString(with: name, style: .paragraphSmallBold, decorations: [.color(.textOnAccent)])

        let count = String(describing: " (\(data.count))")
        let normalCount: NSAttributedString = .attributedString(with: count, style: .paragraphSmall, decorations: [.color(.textSecondary)])
        let selectedCount: NSAttributedString = .attributedString(with: count, style: .paragraphSmall, decorations: [.color(.textOnAccent)])

        normalTitle.append(normalCount)
        selectedTitle.append(selectedCount)

        setAttributedTitle(normalTitle, for: .normal)
        setAttributedTitle(selectedTitle, for: .selected)
    }
}
