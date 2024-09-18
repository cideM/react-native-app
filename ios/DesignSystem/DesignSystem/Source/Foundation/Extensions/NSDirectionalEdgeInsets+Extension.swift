//
//  NSDirectionalEdgeInsets+Extension.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 06.09.23.
//

import UIKit

public extension NSDirectionalEdgeInsets {

    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
