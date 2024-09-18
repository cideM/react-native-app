//
//  AccordionListLayout+Helpers.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 18.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension AccordionListLayout {

    // MARK: - Query layout state

    // Meant to be used by this classes consumer in order to query info about the sections states
    // This way headers and cells can be customized based on it when they are dequeued
    func isSectionExpanded(at index: Int) -> Bool {
        sections[index].isExpanded
    }

    // MARK: - Detecting taps on section headers

    // Convenience method to make the header tappable (to be used by this classes consumer)
    func make(view: UICollectionReusableView, toggle section: Int) {
        if let recognizer = view.gestureRecognizers?.first as? TaggedTapGestureRecognizer {
            recognizer.tag = section
        } else {
            let recognizer = TaggedTapGestureRecognizer(target: self, action: #selector(didTapHeader(sender:)), tag: section)
            view.addGestureRecognizer(recognizer)
        }
    }

    @objc private func didTapHeader(sender: TaggedTapGestureRecognizer) {
        let index = sender.tag
        guard // Get the section object that belongs to the header ...
            let collectionView = collectionView,
            let section = sections.first(where: { $0.index == index })
        else { return }

        guard
            let delegate = delegate,
            delegate.collectionView(collectionView, canExpandSectionAt: index)
        else { return }

        // In case the section was collapsed:
        // Scroll collectionview so the header aligns with top of screen
        let context = UICollectionViewLayoutInvalidationContext()
        let headerIsDocked = section.frame.origin.y <= collectionView.contentOffset.y
        if shouldPinHeaders && section.isExpanded && headerIsDocked {
            let distanceY = collectionView.contentOffset.y - section.frame.origin.y
            context.contentOffsetAdjustment = CGPoint(x: 0, y: -distanceY)
        }

        // Allow the caller to update the header ...
        if let header = sender.view as? UICollectionReusableView {
            let payload = Update.Layout(view: header, index: index, isExpanded: !section.isExpanded)
            delegate.collectionView(collectionView, willUpdateSectionAt: index, with: payload)
        }

        // Actually update the layout ...
        section.isExpanded.toggle()
        invalidateLayout(with: context)
    }
}
