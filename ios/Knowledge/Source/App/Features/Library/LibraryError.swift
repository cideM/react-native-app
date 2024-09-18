//
//  LibraryError.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 10.03.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

enum LibraryError: Error {
    case missingArchive(url: URL)
    case invalidArchive(url: URL)
    case missingLearningCard(identifier: LearningCardIdentifier)
    case missingGallery(identifier: GalleryIdentifier)
    case missingImageResource(identifier: ImageResourceIdentifier)
}
