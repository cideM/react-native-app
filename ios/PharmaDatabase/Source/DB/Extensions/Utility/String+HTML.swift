//
//  String+HTML.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 16.04.21.
//

import Foundation

extension String {

    func bolded(matching text: String) -> String {
        guard !self.isEmpty, let range = self.range(of: text) else { return self }

        let prefix = self[startIndex..<range.lowerBound]
        let bolded = self[range.lowerBound..<range.upperBound]
        let suffix = self[range.upperBound..<endIndex]

        return String()
            .appending(prefix)
            .appending("<b>")
            .appending(bolded)
            .appending("</b>")
            .appending(suffix)
    }
}
