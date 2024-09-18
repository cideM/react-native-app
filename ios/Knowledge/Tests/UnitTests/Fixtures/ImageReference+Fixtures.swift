//
//  ImageReference+Fixtures.swift
//  KnowledgeTests
//
//  Created by CSH on 06.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Domain

extension ImageReference {
    static func fixtures(sources: [URL] = []) -> [ImageReference] {
        sources.map { ImageReference.fixture(source: $0) }
    }
}
