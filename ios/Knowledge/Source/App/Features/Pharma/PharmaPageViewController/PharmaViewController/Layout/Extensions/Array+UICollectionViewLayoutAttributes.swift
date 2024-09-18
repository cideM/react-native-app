//
//  Array+UICollectionViewLayoutAttributes.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 22.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension Array where Element == UICollectionViewLayoutAttributes {

    var maxX: CGFloat {
        var cursor: CGFloat = 0
        for attribute in self {
            cursor = Swift.max(attribute.frame.origin.x + attribute.size.width, cursor)
        }
        return cursor
    }

    var maxY: CGFloat {
        var cursor: CGFloat = 0
        for attribute in self {
            cursor = Swift.max(attribute.frame.origin.y + attribute.size.height, cursor)
        }
        return cursor
    }
}
