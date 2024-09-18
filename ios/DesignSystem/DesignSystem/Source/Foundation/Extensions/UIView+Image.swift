//
//  UIView+Image.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 28.07.23.
//

import UIKit

public extension UIView {
    func image() -> UIImage {
        UIGraphicsImageRenderer(size: frame.size).image { context in
            layer.render(in: context.cgContext)
        }
    }
}
