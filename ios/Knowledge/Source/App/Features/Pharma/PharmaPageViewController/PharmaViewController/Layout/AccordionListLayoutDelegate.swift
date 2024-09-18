//
//  AccordionListLayoutDelegate.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

protocol AccordionListLayoutDelegate: AnyObject {

    // MARK: - Collapse & expand: Headers
    func collectionView(_ collectionView: UICollectionView, canExpandSectionAt index: Int) -> Bool
    func collectionView(_ collectionView: UICollectionView, shouldInitiallyExpandSectionAt index: Int) -> Bool
    func collectionView(_ collectionView: UICollectionView, shouldShowHeaderForSectionAt index: Int) -> Bool

    // MARK: - Spacing: Headers & items
    func collectionView(_ collectionView: UICollectionView, spaceBeforeSectionAt index: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, spaceAfterSectionAt index: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, spaceBeforeItemAt index: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, spaceAfterItemAt indexPath: IndexPath) -> CGFloat

    // MARK: - Headers (User interaction)
    func collectionView(_ collectionView: UICollectionView, willUpdateSectionAt index: Int, with layout: AccordionListLayout.Update.Layout)

    // MARK: - Headers (Size)
    func collectionView(_ collectionView: UICollectionView, heightForHeaderAt index: Int) -> CGFloat
}

extension AccordionListLayout {
    enum Update {
        struct Layout { // swiftlint:disable:this nesting
            let view: UICollectionReusableView?
            let index: Int
            let isExpanded: Bool
        }
    }
}
