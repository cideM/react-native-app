//
//  CGFloat+Constants.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

// MARK: - Convenience CGFloat namespace accessors for numeric tokens
public extension CGFloat {
    static let spacing = Spacing.self
    static let radius = Radius.self
}

// MARK: - MARK: Component height
public extension CGFloat {
    static let h20: CGFloat = 20.0
    static let h24: CGFloat = 24.0
    static let h44: CGFloat = 44.0
    static let h48: CGFloat = 48.0
    static let h200: CGFloat = 200.0
}

// MARK: - State Opacity
public extension CGFloat {
    static let highlightedOpacity = 0.12
    static let disabledOpacity = 0.85
}
