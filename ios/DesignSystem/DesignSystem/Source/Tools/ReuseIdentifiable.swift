//
//  ReusableView.swift
//  Knowledge
//
//  Created by Silvio Bulla on 09.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit

/// A protocol used to identify a view that is reusable
public protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

public extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable {}
extension UITableViewHeaderFooterView: ReuseIdentifiable {}
extension UICollectionReusableView: ReuseIdentifiable {}

public extension UITableView {
    func dequeuedCell<T: UITableViewCell>(for cellType: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as? T else {
            fatalError("Reuse Identifier was not configured")
        }
        return cell
    }
    func dequeuedCell<T: UITableViewCell>() -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Reuse Identifier was not configured")
        }
        return cell
    }
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Reuse Identifier was not configured")
        }
        return view
    }
}

public extension UICollectionView {
    func dequeuedCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Reuse Identifier was not configured")
        }
        return cell
    }
    func dequeueReusableHeaderView<T: UICollectionReusableView>(at indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Reuse Identifier was not configured")
        }
        return view
    }
}
