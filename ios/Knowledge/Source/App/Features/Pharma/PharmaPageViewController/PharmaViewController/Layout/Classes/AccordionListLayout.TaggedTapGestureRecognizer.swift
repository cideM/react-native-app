//
//  AccordionListLayout+Classes.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AccordionListLayout {

    final class TaggedTapGestureRecognizer: UITapGestureRecognizer {
        var tag: Int

        init(target: Any?, action: Selector?, tag: Int) {
            self.tag = tag
            super.init(target: target, action: action)
        }
    }
}
