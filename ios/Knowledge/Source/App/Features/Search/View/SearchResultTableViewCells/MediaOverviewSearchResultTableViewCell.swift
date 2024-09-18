//
//  MediaOverviewSearchResultTableViewCell.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 30.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class MediaOverviewSearchResultTableViewCell: UITableViewCell {

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .canvas
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func configure(items: [MediaSearchOverviewItem]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in items {
            switch item {
            case .mediaViewItem(let mediaViewItem):
                let mediaView = MediaSearchView(mediaItem: mediaViewItem)
                mediaView.heightAnchor.constraint(equalToConstant: 218).isActive = true
                stackView.addArrangedSubview(mediaView)
            case .viewMoreItem(let viewMoreItem):
                let moreView = MediaSearchMoreView(viewMoreItem: viewMoreItem)
                moreView.heightAnchor.constraint(equalToConstant: 218).isActive = true
                stackView.addArrangedSubview(moreView)
            }
        }
        scrollView.setContentOffset(CGPoint(x: -scrollView.safeAreaInsets.left, y: 0), animated: false)
    }

    private func commonInit() {
        selectionStyle = .none
        contentView.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        scrollView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
