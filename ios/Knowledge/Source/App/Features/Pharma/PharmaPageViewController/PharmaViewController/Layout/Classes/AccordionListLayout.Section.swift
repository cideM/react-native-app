//
//  AccordionListLayout.Section.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 22.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AccordionListLayout {

    final class Section {

        var isExpanded: Bool
        var previous: Section?

        var attributes: [UICollectionViewLayoutAttributes] {

            var attributes = [UICollectionViewLayoutAttributes]()
            var cursorY = originY

            if !header.isHidden {
                cursorY += header.padding.top

                let indexPath = IndexPath(index: index)
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
                headerAttributes.zIndex = index + 10 // -> Items further down have higher z to prevent overlapping issues
                headerAttributes.frame = CGRect(x: 0, y: cursorY, width: header.width, height: header.height)
                attributes.append(headerAttributes)

                cursorY += header.height
                cursorY += header.padding.bottom
            }

            if isExpanded {
                for (itemIndex, item) in items.enumerated() {

                    cursorY += item.padding.top

                    let indexPath = IndexPath(item: itemIndex, section: self.index)
                    let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    itemAttributes.zIndex = index + 9  // -> Items further down have higher z to prevent overlapping issues
                    let origin = CGPoint(x: 0, y: cursorY)
                    let size = CGSize(width: header.width, height: item.height)
                    itemAttributes.frame = CGRect(origin: origin, size: size)
                    itemAttributes.isHidden = !isExpanded
                    attributes.append(itemAttributes)

                    cursorY += item.height
                    cursorY += item.padding.bottom
                }
            }

            return attributes
        }

        var itemAttributes: [UICollectionViewLayoutAttributes] {
            attributes.filter {
                $0.representedElementCategory == .cell
            }
        }

        var supplementaryAttributes: [UICollectionViewLayoutAttributes] {
            attributes.filter {
                $0.representedElementCategory == .supplementaryView
            }
        }

        var index: Int {
            var count = 0
            var pointer = previous
            while pointer != nil {
                count += 1
                pointer = pointer?.previous
            }
            return count
        }

        var frame: CGRect {
            let origin = CGPoint(x: 0, y: originY)
            let size = CGSize(width: header.width, height: sectionHeight)
            let frame = CGRect(origin: origin, size: size)
            return frame
        }

        var originY: CGFloat {
            var height = CGFloat(0)
            var pointer = previous
            while pointer != nil {
                height += pointer?.sectionHeight ?? 0
                pointer = pointer?.previous
            }
            return height
        }

        private var sectionHeight: CGFloat {
            var total = CGFloat(0)
            total += header.isHidden ? 0 : header.padding.top + header.height + header.padding.bottom
            for item in items {
                total += isExpanded ? item.padding.top + item.height + item.padding.bottom : 0
            }
            return total
        }

        let items: [Config.Item]
        let header: Config.Header

        init(header: Config.Header, items: [Config.Item], isExpanded: Bool?) {
            self.header = header
            self.items = items
            self.isExpanded = isExpanded ?? false
        }
    }
}
