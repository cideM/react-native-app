//
//  UserDataSynchronizerTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 27.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class UserDataSynchronizerTests: XCTestCase {
    var userDataClient: UserDataClientMock!
    var userDataRepository: UserDataRepositoryTypeMock!
    var userDataSynchroniser: UserDataSynchronizer!

    override func setUp() {
        userDataClient = UserDataClientMock()
        userDataRepository = UserDataRepositoryTypeMock()
        userDataSynchroniser = UserDataSynchronizer(userDataClient: userDataClient, userDataRepository: userDataRepository)
    }
}
