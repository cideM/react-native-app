//
//  UIFont+TypeFace.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public protocol TypeFace: TokenRepresentable where RawValue == String {
    static var familyName: String { get }
    static var variations: [String] { get }
}

extension UIFont {
    convenience init(typeFace: any TypeFace, size: CGFloat) {
        // swiftlint:disable:next force_unwrapping
        self.init(name: typeFace.rawValue, size: size)!
    }
}
