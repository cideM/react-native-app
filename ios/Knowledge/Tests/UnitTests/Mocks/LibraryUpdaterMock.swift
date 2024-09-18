//
//  LibraryUpdaterMock.swift
//  KnowledgeTests
//
//  Created by CSH on 22.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Knowledge_DE

class LibraryUpdaterMock: LibraryUpdaterType {

    var onSetIsBackgroudUpdatesEnabledCount = 0
    var onSetIsBackgroudUpdatesEnabled: (Bool) -> Void = { _ in }
    var onGetIsBackgroudUpdatesEnabledCount = 0
    var onGetIsBackgroudUpdatesEnabled: () -> Bool = { true }
    var isBackgroundUpdatesEnabled: Bool {
        get {
            onGetIsBackgroudUpdatesEnabledCount += 1
            return onGetIsBackgroudUpdatesEnabled()
        }
        set {
            onSetIsBackgroudUpdatesEnabledCount += 1
            onSetIsBackgroudUpdatesEnabled(newValue)
        }
    }

    var onGetStateCount = 0
    var onGetState: () -> LibraryUpdaterState = { .upToDate }
    var state: LibraryUpdaterState {
        onGetStateCount += 1
        return onGetState()
    }

    var onUpdateCount = 0
    var onUpdate: (_ isUserTriggered: Bool) -> Void = { _ in }
    func initiateUpdate(isUserTriggered: Bool) {
        onUpdateCount += 1
        onUpdate(isUserTriggered)
    }
}
