//
//  UIImage+Color.swift
//  bytes
//
//  Created by Cornelius Horstmann on 06.06.18.
//  Copyright © 2018 TBO INTERACTIVE GmbH & Co. KG. All rights reserved.
//
import UIKit

public extension UIImage {
    /// An NSCache used to cache images generates by the `UIImage.from(color)` function.
    /// Per default this is non nil and has a `countLimit` of 10.
    /// Set this to nil to deactivate caching at all. Set the `countLimit` of this
    /// chache to 0 if you want to define no caching limit.
    @objc static var imageFromColorCache: NSCache<UIColor, UIImage>? = {
        let cache = NSCache<UIColor, UIImage>()
        cache.countLimit = 10
        return cache
    }()

    /// Generates an image of size 1x1 pixel filled with just one color.
    /// Before generating the image the `UIImage.imageFromColorCache` will
    /// be searched for an existing image of this color.
    ///
    /// - Parameter color: The color of the image.
    /// - Returns: A 1x1 pixes image filled with that color.
    @objc static func from(_ color: UIColor) -> UIImage {
        if let image = imageFromColorCache?.object(forKey: color) {
            return image
        }
        let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()! // swiftlint:disable:this force_unwrapping
        context.setFillColor(color.cgColor)
        context.fill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()! // swiftlint:disable:this force_unwrapping
        UIGraphicsEndImageContext()
        imageFromColorCache?.setObject(image, forKey: color)
        return image
    }
}

extension UIImage {
    func image(withTint tint: UIColor) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(origin: .zero, size: size)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.clip(to: rect, mask: cgImage)
        tint.setFill()
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()! // swiftlint:disable:this force_unwrapping
        UIGraphicsEndImageContext()
        return image
    }
}
