//
//  MediaSearchResultCollectionViewCell.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 12.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class MediaSearchResultCollectionViewCell: UICollectionViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func configure(item: MediaSearchViewItem) {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let mediaSearchView = MediaSearchView(mediaItem: item)
        mediaSearchView.translatesAutoresizingMaskIntoConstraints = false
        mediaSearchView.setImageAspectRatio(1)
        contentView.addSubview(mediaSearchView)
        mediaSearchView.constrain(to: contentView)
    }
}
