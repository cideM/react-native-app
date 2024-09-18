//
//  Array+Distinct.swift
//  RichTextRenderer
//
//  Created by Silvio Bulla on 10.02.21.
//

import Foundation

extension Array where Element: Hashable {

    public func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
