//
//  AccordionListLayout+Helpers.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AccordionListLayout {

    func setupLayoutObjects(for collectionView: UICollectionView) -> [Section] {

        var sections = [Section]()
        let sectionsCount = collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0
        for sectionIndex in 0..<sectionsCount {

            var items = [Section.Config.Item]()
            let itemsCount = collectionView.numberOfItems(inSection: sectionIndex)
            for itemIndex in 0..<itemsCount {

                // Abuse prefetched cell height calculations, we only need the height ...
                let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                if let cell = collectionView.dataSource?.collectionView(collectionView, cellForItemAt: itemIndexPath) {
                    let baseSize = CGSize(width: collectionView.bounds.width, height: 1) // <- "1" is important it only grows but does not shrink!
                    let size = cell.systemLayoutSizeFitting(baseSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
                    let top = delegate?.collectionView(collectionView, spaceBeforeItemAt: itemIndexPath) ?? 0
                    let bottom = delegate?.collectionView(collectionView, spaceAfterItemAt: itemIndexPath) ?? 0
                    let padding = Section.Config.Offset(top: top, bottom: bottom)
                    let item = Section.Config.Item(height: size.height, padding: padding)
                    items.append(item)
                }
            }

            // Setup header ...
            let shouldShowHeader = delegate?.collectionView(collectionView, shouldShowHeaderForSectionAt: sectionIndex) ?? true
            let top = delegate?.collectionView(collectionView, spaceBeforeSectionAt: sectionIndex) ?? 0
            let bottom = delegate?.collectionView(collectionView, spaceAfterSectionAt: sectionIndex) ?? 0
            let isExpanded = delegate?.collectionView(collectionView, shouldInitiallyExpandSectionAt: sectionIndex)
            let padding = Section.Config.Offset(top: top, bottom: bottom)

            let headerHeight = delegate?.collectionView(collectionView, heightForHeaderAt: sectionIndex) ?? Self.defaultHeaderHeight
            let header = Section.Config.Header(width: collectionView.bounds.width, height: headerHeight, isHidden: !shouldShowHeader, padding: padding)
            let section = Section(header: header, items: items, isExpanded: isExpanded)

            sections.append(section)
        }

        // Each section calculates layout based on previous ones in the list
        // Hence each one needs to know its predecessor
        sections.link()

        return sections
    }
}
