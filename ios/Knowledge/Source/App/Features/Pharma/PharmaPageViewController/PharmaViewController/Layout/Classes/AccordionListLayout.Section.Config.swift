//
//  AccordionListLayout.Section.Config.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 22.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AccordionListLayout.Section {
    enum Config {}
}

extension AccordionListLayout.Section.Config {

    struct Header {
        let width: CGFloat
        let height: CGFloat
        let isHidden: Bool
        let padding: Offset

        init(width: CGFloat, height: CGFloat, isHidden: Bool, padding: Offset = .init()) {
           self.width = width
           self.height = height
           self.isHidden = isHidden
           self.padding = padding
       }
    }

    struct Item {
        let height: CGFloat
        let padding: Offset

        init(height: CGFloat, padding: Offset = .init()) {
            self.height = height
            self.padding = padding
        }
    }

    struct Offset {
        let top: CGFloat
        let bottom: CGFloat

        init(top: CGFloat = 0, bottom: CGFloat = 0) {
            self.top = top
            self.bottom = bottom
        }
    }
}
