//
//  String+Range.swift
//  Common
//
//  Created by Aamir Suhial Mir on 07.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension String {
    func ranges(of subString: String, options: CompareOptions = [], in range: Range<Index>? = nil) -> [Range<Index>] {
        guard let range = self.range(of: subString, options: options, range: range) else { return [] }
        return [range] + self.ranges(of: subString, options: options, in: range.upperBound ..< self.endIndex)
    }
}
