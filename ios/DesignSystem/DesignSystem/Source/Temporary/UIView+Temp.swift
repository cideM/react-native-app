//
//  UIView+Shadow.swift
//  DesignSystem
//
//  Created by Mohamed Abdul Hameed on 17.12.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class ElevatedView: UIView {

    private let elevation: Elevation
    private let cornerRadius: CGFloat

    private var borderLayer: CALayer?
    private var shadowLayers: [CALayer] = []

    public init(elevation: Elevation, cornerRadius: CGFloat = 0) {
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        applyShadows()
        applyBorder()
    }

    private func applyShadows() {
        shadowLayers.forEach { $0.removeFromSuperlayer() }

        for shadow in elevation.shadows {
            let shadowLayer = CALayer()
            shadowLayer.masksToBounds = false
            shadowLayers.append(shadowLayer)
            shadowLayer.addShadow(color: shadow.shadowColor,
                                  opacity: 1,
                                  offset: shadow.shadowOffset,
                                  path: UIBezierPath(roundedRect: bounds,
                                                     cornerRadius: cornerRadius).cgPath)
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    private func applyBorder() {
        borderLayer?.removeFromSuperlayer()

        let borderLayer = CALayer()
        let borderWidth = elevation.borderWidth
        borderLayer.cornerRadius = cornerRadius
        borderLayer.frame = CGRect(x: -borderWidth, y: -borderWidth, width: frame.size.width + 2 * borderWidth, height: frame.size.height + 2 * borderWidth)
        borderLayer.borderColor = elevation.borderColor.cgColor
        borderLayer.borderWidth = borderWidth
        self.borderLayer = borderLayer
        self.layer.insertSublayer(borderLayer, at: 0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        applyShadows()
        applyBorder()
    }
}

public extension CALayer {
    func addShadow(color: UIColor, opacity: Float, offset: CGSize, path: CGPath? = nil) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = offset
        if let path = path {
            shadowPath = path
            shouldRasterize = true
            rasterizationScale = UIScreen.main.scale
        }
    }
}
