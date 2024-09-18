//
//  String+htmlTagsStripped.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 18.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension String {
    func htmlTagsStripped(using encoding: Encoding = .utf16) -> String? {
        guard
            let data = data(using: encoding),
            let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else { return nil }

        return attributedString.string
    }
}
