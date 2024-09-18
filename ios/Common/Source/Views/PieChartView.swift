//
//  PieChartBadge.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 17.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit

public final class PieChartView: UIView {
    /// The background layer of the pie chart view.
    private let backgroundLayer = CAShapeLayer()

    /// The foreground layer of the pie chart view.
    private let foregroundLayer = CAShapeLayer()

    /// Initializes a new PieChartView with given fourground and background colors.
    ///
    /// - Parameter backgroundLayerColor: The background of the pie chart
    /// - Parameter foregroundLayerColor: The foreground of the pie char
    public init(backgroundLayerColor: UIColor, foregroundLayerColor: UIColor) {
        super.init(frame: .zero)

        backgroundLayer.fillColor = backgroundLayerColor.cgColor
        foregroundLayer.fillColor = foregroundLayerColor.cgColor

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(foregroundLayer)

        backgroundColor = ThemeManager.currentTheme.backgroundTransparentColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        foregroundLayer.frame = bounds
        backgroundLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }

    /// Draws pie inner circle arch.
    /// - Parameter progress: CGFloat: based on progress the angle of pie arch is computed.
    public func setProgress(_ value: Float) {
        let halfOfViewDimensions = min(bounds.size.width / 2, bounds.size.height / 2)
        let center = CGPoint(x: halfOfViewDimensions, y: halfOfViewDimensions)

        let radius = min(frame.width, frame.height) / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat(value) * CGFloat.pi * 2

        let innerCirclePath = UIBezierPath()
        innerCirclePath.move(to: center)
        innerCirclePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        foregroundLayer.path = innerCirclePath.cgPath

        let outerCirclePath = UIBezierPath()
        outerCirclePath.move(to: center)
        outerCirclePath.addArc(withCenter: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        backgroundLayer.path = outerCirclePath.cgPath
    }
}
