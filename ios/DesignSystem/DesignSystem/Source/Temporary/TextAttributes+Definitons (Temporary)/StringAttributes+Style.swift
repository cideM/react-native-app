//
//  TextAttributes+Definitons.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 12.04.23.
//

import UIKit

public extension Dictionary where Key == NSAttributedString.Key, Value == Any {

    static let inlineLink: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.textAccent,
        .underlineColor: UIColor.textAccent,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
}
