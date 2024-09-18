//
//  NSAttributedString+SettingAttributes.swift
//  Common
//
//  Created by CSH on 13.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension NSAttributedString {

    /// Returns a new NSAttributedString where the attribute with a given key
    /// is set to a given value for the full range.
    ///
    /// - Parameters:
    ///   - key: The key of the attribute to set.
    ///   - value: The value of the attribute to set.
    /// - Returns: Returns a new NSAttributedString where the attribute has been set
    @objc func settingAttribute(key: NSAttributedString.Key, value: Any) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        return mutableAttributedString.settingAttribute(key: key, value: value)
    }

}

public extension NSMutableAttributedString {

    @objc override func settingAttribute(key: NSAttributedString.Key, value: Any) -> NSMutableAttributedString {
        let copy = self
        copy.addAttribute(key, value: value, range: NSRange(location: 0, length: string.count))
        return copy
    }

    func addAttributes(_ attrs: [NSAttributedString.Key: Any] = [:], range: Range<String.Index>) {

        let nsRange = NSRange(range, in: string)

        // WORKAROUND:
        // The range might be out of bounds in case the string contains a german "umlaut" (äöü)
        // Searching for "Befundung eines Röntgen-Thorax" will crash on the device only (iOS15.3.1)
        // Skip adding the attributes mitigates the crash
        // I was not able to find another way of fixing this ...
        guard nsRange.location + nsRange.length <= length else { return }

        addAttributes(attrs, range: nsRange)
    }
}

public extension NSMutableAttributedString {

    func trimmingCharacters(in set: CharacterSet) -> NSMutableAttributedString {
        let trimmedString = string.trimmingCharacters(in: set)
        let trimmedRange = NSString(string: string).range(of: trimmedString)
        if trimmedRange.location == NSNotFound || trimmedRange.length == 0 {
            return NSMutableAttributedString(string: "")
        }
        if let trimmedString = attributedSubstring(from: trimmedRange).mutableCopy() as? NSMutableAttributedString {
            return trimmedString
        } else {
            return self
        }
    }
}
