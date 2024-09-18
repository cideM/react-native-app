//
//  Array+Helpers.swift
//  Common
//
//  Created by Silvio Bulla on 25.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    func arrayWithElementsSeparated(by separator: Element) -> [Element] {
        let arrayOfArrays = self.map { [ $0 ] }
        return Array(arrayOfArrays.joined(separator: [separator]))
    }
}
