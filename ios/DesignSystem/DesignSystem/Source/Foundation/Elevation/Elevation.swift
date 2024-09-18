//
//  Elevation.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 06.09.23.
//

import UIKit

public struct Elevation {
    let borderWidth: CGFloat
    let borderColor: UIColor
    let shadows: [Shadow]
}

public struct Shadow {
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
    let shadowColor: UIColor
}
