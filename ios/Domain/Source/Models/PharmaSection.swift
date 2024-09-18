//
//  PharmaSection.swift
//  Interfaces
//
//  Created by Silvio Bulla on 19.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PharmaSection {

    public let title: String
    public let text: String?
    public let position: Int?

    public init(title: String, text: String?, position: Int?) {
        self.title = title
        self.text = text
        self.position = position
    }
}
