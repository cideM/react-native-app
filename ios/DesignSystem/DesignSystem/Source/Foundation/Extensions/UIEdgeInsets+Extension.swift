//
//  UIEdgeInsets+Extension.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 05.06.23.
//

import UIKit

public extension UIEdgeInsets {

    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
