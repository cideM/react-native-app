//
//  UICollectionViewDataSource+Extensions.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 22.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UICollectionViewDataSource {

    func hash(for view: UICollectionView) -> Int {
        var hashArray = [Int]()
        for sectionIndex in 0..<(numberOfSections?(in: view) ?? 0) {
            hashArray.append(sectionIndex)

            for itemIndex in 0..<collectionView(view, numberOfItemsInSection: sectionIndex) {
                hashArray.append(itemIndex)
            }
        }

        return hashArray.hashValue
    }
}
