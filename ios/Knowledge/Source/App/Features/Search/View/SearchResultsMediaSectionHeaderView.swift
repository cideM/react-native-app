//
//  SearchResultsMediaSectionHeaderView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 26.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import UIKit
import DesignSystem

class SearchResultsMediaSectionHeaderView: UICollectionReusableView {

    private var filterTagButtons: [TagButton] = []
    private var selectedTagButton: TagButton?

    private lazy var filtersTagsView: TilingContainerView = {
        let tilingContainerView = TilingContainerView()
        tilingContainerView.isMultipleLines = false
        tilingContainerView.translatesAutoresizingMaskIntoConstraints = false
        return tilingContainerView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .backgroundPrimary
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func configure(filters: [SearchFilterViewItem]) {

        filterTagButtons.forEach { $0.removeFromSuperview() }
        filterTagButtons = []
        selectedTagButton = nil

        for filter in filters {
            let tagButton = TagButton.styled(for: filter)
            tagButton.setTitle(with: filter)

            tagButton.isSelected = filter.isActive

            if tagButton.isSelected {
                selectedTagButton = tagButton
            }

            tagButton.touchUpInsideActionClosure = { [weak self, filters] in
                guard let self = self else { return }

                let isActive = !filter.isActive
                for (filter, button) in zip(filters, self.filterTagButtons) {
                    filter.isActive = false
                    button.isSelected = false
                }
                filter.isActive = isActive
                tagButton.isSelected = isActive
                self.selectedTagButton = isActive ? tagButton : nil

                filter.tapClosure(filter)
            }

            filterTagButtons.append(tagButton)
            filtersTagsView.addSubview(tagButton)
        }

        scrollView.flashScrollIndicators()
    }

    private func commonInit() {
        addSubview(scrollView)
        scrollView.addSubview(filtersTagsView)
        scrollView.constrainEdges(to: self)
        NSLayoutConstraint.activate([

            filtersTagsView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            filtersTagsView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            filtersTagsView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            filtersTagsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            filtersTagsView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor, constant: 16),
            filtersTagsView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor, constant: -16)
        ])

    }

    func scrollToSelected() {
        if let selectedTagButton = self.selectedTagButton {
            self.layoutIfNeeded()
            let offset = CGPoint(x: min(selectedTagButton.frame.origin.x, scrollView.contentSize.width - scrollView.frame.width), y: 0)
            self.scrollView.setContentOffset(offset, animated: false)
        }
    }
}
