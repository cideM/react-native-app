//
//  MessagePresenterMock.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 31.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
@testable import Knowledge_DE

class MessagePresenterMock: MessagePresenter {
    var onPresentCount = 0
    var onPresent: (PresentableMessageType, [MessageAction]) -> Void = { _, _ in }
    func present(_ message: PresentableMessageType, actions: [MessageAction]) {
        onPresentCount += 1
        onPresent(message, actions)
    }
}
