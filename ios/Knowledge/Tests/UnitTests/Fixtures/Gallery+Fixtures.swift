//
//  Gallery+Fixtures.swift
//  KnowledgeTests
//
//  Created by CSH on 06.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Domain

extension Gallery {
    static func fixture(id: Domain.GalleryIdentifier = .fixture(), imageResourceIdentifiers: [ImageResourceIdentifier] = []) -> Gallery {
        Gallery(id: id, sortableImages: SortableImageReference.fixtures(imageResourceIdentifiers: imageResourceIdentifiers))
    }
}
