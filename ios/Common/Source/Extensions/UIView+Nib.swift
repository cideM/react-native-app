//
//  UIView+Nib.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

public extension UIView {

    /// Tries to initialize a view from a xib with the name of the class
    /// in the bundle of the class and returns the first view of the correct type if any.
    ///
    /// This function is a convenience function for the more complex `fromNib(:, bundle:, type: )`
    /// and automatically calculates nib name, bundle and especially the type.
    /// This function is especially helpful for subclasses of UIView. Used on UIView it always
    /// tries to initialize a UIView in a UIView.xib in the UIKit bundle and thus returns nil.
    ///
    /// - Returns: Returns the first view
    static func fromNib() -> Self? {
        fromNib(nil, bundle: nil, type: self)
    }

    /// Tries to initialize a view from a xib. To do that it searches in a bundle for a nib
    /// with a given name, initializes it and returns the first view of the correct type if any.
    ///
    /// - Parameters:
    ///   - nibName: The name of the nib. Uses the classname if not defined.
    ///   - bundle: The bundle of the nib. Uses the bundle of the current class if not defined or nil.
    ///   - type: The type of the view your are expecting.
    /// - Returns: The initialized view or nil if none found or unable to initialize.
    static func fromNib<T: UIView>(_ nibName: String? = nil, bundle: Bundle? = nil, type: T.Type) -> T? {
        let nibName = nibName ?? String(describing: type)
        let bundle = bundle ?? Bundle(for: type)
        if bundle.path(forResource: nibName, ofType: "nib") != nil {
            if let views = bundle.loadNibNamed(nibName, owner: self, options: nil) {
                for view in views {
                    if let casted = view as? T {
                        return casted
                    }
                }
            }
        }
        return nil
    }
}
