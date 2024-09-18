//
//  PharmaSectionHeader+Config.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 18.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import DesignSystem

extension PharmaSectionHeader {

    func configure(at index: Int, with data: PharmaViewData.SectionViewData, isExpanded: Bool, animated: Bool) {
        let attributes: [NSAttributedString.Key: Any]

        switch data {
        case .substance, .drug, .prescribingInfo, .feedback, .section:
            emptyLabel.isHidden = data.isExpandable
            arrowImageView.isHidden = !data.isExpandable

            let expanded = UIColor.backgroundSecondary
            let collapsed = UIColor.backgroundPrimary
            backgroundColorView.backgroundColor = isExpanded ? expanded : collapsed

            attributes = .attributes(style: .paragraphBold)

            UIView.animate(withDuration: animated ? 0.3 : 0.0) { [weak self] in
                self?.arrowImageView.transform = isExpanded ? CGAffineTransform(scaleX: 1, y: -1) : .identity
            }

        case .simpleTitle, .segmentedControl:
            emptyLabel.isHidden = true
            arrowImageView.isHidden = true
            backgroundColorView.backgroundColor = .backgroundPrimary
            attributes = .attributes(style: .paragraphBold)
        }
        titleLabel.attributedText = NSAttributedString(string: data.title ?? "", attributes: attributes)
    }
}
