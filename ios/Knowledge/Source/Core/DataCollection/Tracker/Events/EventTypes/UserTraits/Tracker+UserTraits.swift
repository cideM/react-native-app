//
//  Analytics+UserTraits.swift
//  Knowledge
//
//  Created by Elmar Tampe on 14.07.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

extension Tracker {
    enum UserTraits {
        case user(User?)
        case deviceId(String?)
        case stage(UserStage?)
        case studyObjective(StudyObjective?)
        case libraryMetadata(LibraryMetadata?)
        case variant(AppVariant)
        case features([String])
    }
}
