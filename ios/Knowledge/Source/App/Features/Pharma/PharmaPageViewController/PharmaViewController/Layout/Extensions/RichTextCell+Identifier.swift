//
//  RichTextCell+Identifier.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 30.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import RichTextRenderer

extension RichTextCell {

    static func uniqueReuseIdentifier(with viewData: PharmaViewData.SectionViewData) -> String? {
        var itemData: PharmaSectionViewData?

        switch viewData {
        case .section(let data): itemData = data
        default: break
        }

        if let data = itemData {
            return "\(data.hashValue)"
        } else {
            return nil
        }
    }
}
