//
//  UITextField+Typography.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public extension UITextField {

    // MARK: Text Setting
    func set(text: String,
             style: Typography,
             textColor color: UIColor? = nil,
             textAlignment alignment: NSTextAlignment? = nil,
             readjustsFontSize: Bool? = nil) {

        translatesAutoresizingMaskIntoConstraints = false
        attributedText = style.attributedString(from: text)
        alignment.map({ textAlignment = $0 })
        readjustsFontSize.map({ adjustsFontSizeToFitWidth = $0 })
        color.map({ textColor = $0 })
    }

    // MARK: Placeholder Setting
    func set(placeholder: String, style: Typography) {
        attributedPlaceholder = style.attributedString(from: placeholder)
    }

    func set(placeholder: String,
             style: Typography,
             textColor color: UIColor,
             textAlignment alignment: NSTextAlignment,
             readjustsFontSize: Bool) {

        translatesAutoresizingMaskIntoConstraints = false
        set(placeholder: placeholder, style: style)
        textAlignment = alignment
        adjustsFontSizeToFitWidth = readjustsFontSize
        textColor = color
    }
}
