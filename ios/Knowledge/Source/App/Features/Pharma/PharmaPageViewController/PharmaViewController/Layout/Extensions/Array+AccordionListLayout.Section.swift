//
//  Array+AccordionListLayout.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 22.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension Array where Element == AccordionListLayout.Section {

    subscript(rect: CGRect) -> [AccordionListLayout.Section] {
        filter { section in
            section.attributes.contains { attribute in
                rect.intersects(attribute.frame)
            }
        }
    }

    func link() {
        var previous: AccordionListLayout.Section?
        for section in self {
            section.previous = previous
            previous = section
        }
    }

    func pinHeaders(at offsetY: CGFloat) -> [UICollectionViewLayoutAttributes] {
        var headerAttributes = [UICollectionViewLayoutAttributes]()
        // Pin headers to top ...
        for section in self {
            let isSectionOverlappingTopScreenBorder = section.frame.contains(CGPoint(x: 0, y: offsetY))
            for attribute in section.supplementaryAttributes {
                // Make header sticky if section is expanded AND on top screen border ...
                if section.isExpanded && isSectionOverlappingTopScreenBorder {
                    let posY = Swift.max(attribute.frame.origin.y, offsetY)
                    attribute.frame.origin.y = posY
                }
                headerAttributes.append(attribute)
            }
        }

        // Make sure headers push each other of screen when dragging
        // This looks nicer than just pushing them on top of each other ...
        var sortedHeaderAttributes = [UICollectionViewLayoutAttributes]()
        while let attribute = headerAttributes.popLast() {
            if let previousAttribute = headerAttributes.last, previousAttribute.frame.intersects(attribute.frame) {
                let offsetY = previousAttribute.frame.intersection(attribute.frame).height
                previousAttribute.transform = .init(translationX: 0, y: -offsetY)
            }
            sortedHeaderAttributes.append(attribute)
        }

        return itemAttributes + sortedHeaderAttributes
    }

    var attributes: [UICollectionViewLayoutAttributes] {
        flatMap { section in
            section.attributes
        }
    }

    var supplementaryAttributes: [UICollectionViewLayoutAttributes] {
        flatMap { section in
            section.supplementaryAttributes
        }
    }

    var itemAttributes: [UICollectionViewLayoutAttributes] {
        flatMap { section in
            section.itemAttributes
        }
    }

    var frame: CGRect {
        var minX = CGFloat(0)
        var minY = CGFloat(0)
        var maxX = CGFloat(0)
        var maxY = CGFloat(0)

        for section in self {
            minX = Swift.min(maxX, section.frame.origin.x)
            minY = Swift.min(maxY, section.frame.origin.y)
            maxX = Swift.max(maxX, section.frame.maxX)
            maxY = Swift.max(maxY, section.frame.maxY)
        }

        let origin = CGPoint(x: minX, y: minY)
        let size = CGSize(width: maxX, height: maxY)
        let rect = CGRect(origin: origin, size: size)

        return rect
    }
}
