//
//  PharmaViewController+FoldabeFlowLayoutDelegate.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension PharmaViewController: AccordionListLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, canExpandSectionAt index: Int) -> Bool {
        // Sections won't expand if there is no content but the header will still be visible
        // Example: "Rote Hand"
        sections[index].isExpandable
    }

    func collectionView(_ collectionView: UICollectionView, shouldShowHeaderForSectionAt index: Int) -> Bool {
        // These sections are usually initially expanded
        // They are used as "blocks of content" in between the "foldable" list
        // In this case these are:
        // * .agent and .drug - at the top of the list
        // * .simpleTitle, .prescribingInfo - near end of list
        sections[index].isHeaderVisble
    }

    func collectionView(_ collectionView: UICollectionView, shouldInitiallyExpandSectionAt index: Int) -> Bool {
        // "Rote Hand" is expanded initially in case it has been recently updated ...
        sections[index].isExpanded
    }

    func collectionView(_ collectionView: UICollectionView, willUpdateSectionAt index: Int, with layout: AccordionListLayout.Update.Layout) {
        guard let header = layout.view as? PharmaSectionHeader else { return }
        let isExpanded = !self.layout.isSectionExpanded(at: index) // <- Inverse cause not expanded yet!
        header.configure(at: index, with: sections[index], isExpanded: isExpanded, animated: true)
        presenter.pharmaSectionTapped(section: sections[index], isExpanded: isExpanded)
    }

    func collectionView(_ collectionView: UICollectionView, spaceBeforeSectionAt index: Int) -> CGFloat {
        switch sections[index] {
        case .section: 1
        default: 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, spaceAfterSectionAt index: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, spaceBeforeItemAt index: IndexPath) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, spaceAfterItemAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .substance, .prescribingInfo: 0
        case .segmentedControl: 0
        default: 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, heightForHeaderAt index: Int) -> CGFloat {
        switch sections[index] {
        case .simpleTitle:
            42
        default:
            AccordionListLayout.defaultHeaderHeight
        }
    }
}
