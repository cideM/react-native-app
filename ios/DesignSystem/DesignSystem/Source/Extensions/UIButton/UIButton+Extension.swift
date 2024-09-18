//
//  UIButton+Extension.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

extension UIButton {

    func setBackgroundColor(_ color: UIColor,
                            borderColor: UIColor? = nil,
                            for state: UIControl.State,
                            addHighlightOverlay: Bool = false) {

        let bounds = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        let insetValue = 1.0
        let lineWidth = 1.0

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.clear(bounds)

        let insetRect = bounds.insetBy(dx: insetValue, dy: insetValue)
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: .radius.xs)
        ctx.beginPath()
        ctx.addPath(path.cgPath)
        ctx.closePath()
        ctx.saveGState()
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
        ctx.restoreGState()

        if addHighlightOverlay {
            let insetRect = bounds.insetBy(dx: insetValue, dy: insetValue)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: .radius.xs)
            ctx.saveGState()
            ctx.beginPath()
            ctx.addPath(path.cgPath)
            ctx.closePath()
            ctx.setFillColor(UIColor.black.withAlphaComponent(0.05).cgColor)
            ctx.fillPath()
            ctx.restoreGState()
        }

        if let borderColor = borderColor {
            let insetRect = bounds.insetBy(dx: insetValue + (lineWidth / 2.0), dy: insetValue + (lineWidth / 2.0))
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: .radius.xs)
            ctx.saveGState()
            ctx.beginPath()
            ctx.addPath(path.cgPath)
            ctx.closePath()
            ctx.setStrokeColor(borderColor.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.strokePath()
            ctx.restoreGState()
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let resizableImgage = image?.resizableImage(withCapInsets: .init(horizontal: 4.0, vertical: 4.0),
                                                    resizingMode: .stretch)

        setBackgroundImage(resizableImgage, for: state)
    }
}
