//
//  SortableImageReference+Fixtures.swift
//  KnowledgeTests
//
//  Created by CSH on 06.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Domain

extension Gallery.SortableImageReference {
    static func fixtures(imageResourceIdentifiers: [ImageResourceIdentifier] = [.fixture()]) -> [Gallery.SortableImageReference] {
        imageResourceIdentifiers.enumerated().map { index, identifier in
            Gallery.SortableImageReference(imageIndex: "\(index)", imageResource: identifier)
        }
    }
}
