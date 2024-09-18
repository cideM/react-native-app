//
//  CollapsibleSectionsLayout.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 12.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import RichTextRenderer
import UIKit

final class AccordionListLayout: UICollectionViewLayout {

    static let defaultHeaderHeight: CGFloat = 56

    weak var delegate: AccordionListLayoutDelegate?
    var shouldPinHeaders = true

    // Combination of sections or items generate a unique hash
    // Recorded in order to determine if layout needs to be rebuilt
    private var dataSourceHash: Int?

    private var observation: NSKeyValueObservation?

    override var collectionViewContentSize: CGSize {
        CGSize(width: sections.attributes.maxX, height: sections.attributes.maxY)
    }

    private(set) var sections = [Section]()

    // MARK: - Init

    init(delegagte: AccordionListLayoutDelegate? = nil) {
        super.init()
        self.delegate = delegagte
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Template methods

    override func prepare() {
        guard
            let collectionView = collectionView,
            let dataSource = collectionView.dataSource
        else { return }

        if observation == nil {
            // WORKAROUND iOS15+:
            // Layout should actually be invalidated via shouldInvalidateLayout(forBoundsChange:)
            // Turns out this is not being called when rotating from landscape to portrait (only the other way around)
            // By observing the bounds (not the frame - does not fire) we can invalidate the layout manually here ...
            observation = collectionView.observe(\UICollectionView.bounds, options: [.old, .new]) { _, change in
                guard change.oldValue?.size.width != change.newValue?.size.width else { return }
                // WORKAROUND: iOS15+
                // Cells that have been visible directly before the rotation are not removed
                // This means we end up with a full set of cell that still have dimensions
                // tailored to the previous screen size -> visual artifacts
                // Brute forcing this "out of context" reload on the view seems to fix it
                // This was tested on iOS17 and it is still required!
                self.dataSourceHash = nil // -> Rebuild layout attributes
                self.sections = []
                self.invalidateLayout()
                collectionView.reloadData()
            }
        }

        // Only rebuild layout if section or item count changed
        // Everything else is calculated on the fly via "func layoutAttributesFor...()"
        let hash = dataSource.hash(for: collectionView)
        if hash != dataSourceHash {
            dataSourceHash = hash
            sections = setupLayoutObjects(for: collectionView)
        }

        super.prepare()
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        prepare()
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        // This is true if .reloadData() was called ...
        if context.invalidateEverything {
            self.dataSourceHash = nil // -> Rebuild layout attributes
            self.sections = []
        }

        // This is also called if sections are expanded or collapsed.
        // In this case we do not need to rebuild the layout data.
        // It dynamically takes this into account based on the data it already has.
        // Rebuilding the data would lead to expanded sections disappearing ...
        super.invalidateLayout(with: context)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        sections.itemAttributes.first {
            $0.indexPath == indexPath
        }
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        sections.supplementaryAttributes.first {
            $0.indexPath == indexPath
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let dirtySections = sections[rect]

        if shouldPinHeaders {
            return dirtySections.pinHeaders(at: collectionView.contentOffset.y)
        } else {
            return dirtySections.attributes
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Rebuild layout if:
        // * Collectionviews size did change ( -> see WORKAROUND above)
        // * Any section is expanded (required for sticky header while scrolling)
        if shouldPinHeaders && sections[newBounds].contains(where: { $0.isExpanded && !$0.header.isHidden }) {
            // Only needs to stick headers (for expanded sections) to top of screen while scrolling
            // Which is done on the fly in "func layoutAttributesFor(...)"
            return true
        } else {
            return false
        }
    }

    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        // This is only relevant for updates that are triggered from self sizing cells
        // We dont have those, hence disable this ...
        false
    }
}
