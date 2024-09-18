//
//  FeedbackContext.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 23.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct FeedbackContext: Codable {
    public let context: SectionContext?
}

public struct SectionContext: Codable {
    public let modelId: String
    public let modelVersion: Int?
}
