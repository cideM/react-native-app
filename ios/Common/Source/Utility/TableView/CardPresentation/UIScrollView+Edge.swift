//
//  UIScrollView+Edge.swift
//  Common
//
//  Created by Azadeh Richter on 03.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UIScrollView {

    var isAtTop: Bool {
        contentOffset.y <= verticalOffsetForTop
    }

    var isAtBottom: Bool {
        contentOffset.y >= verticalOffsetForBottom
    }

    var isAtLeft: Bool {
        contentOffset.x <= horizontalOffsetForLeft
    }

    var isAtRight: Bool {
        contentOffset.x >= horizontalOffsetForRight
    }

    var verticalOffsetForTop: CGFloat {
        contentInset.top
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }

    var horizontalOffsetForLeft: CGFloat {
        contentInset.left
    }

    var horizontalOffsetForRight: CGFloat {
        let scrollViewWidth = bounds.width
        let scrollContentSizeWidth = contentSize.width
        let rightInset = contentInset.right
        let scrollViewRightOffset = scrollContentSizeWidth + rightInset - scrollViewWidth
        return scrollViewRightOffset
    }
 }
