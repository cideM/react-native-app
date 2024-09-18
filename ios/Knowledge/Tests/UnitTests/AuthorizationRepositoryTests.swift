//
//  AuthorizationRepositoryTests.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

import Foundation

class AuthorizationRepositoryTests: XCTestCase {
    private var authorizationRepository: AuthorizationRepository! = nil

    override func setUp() {
        authorizationRepository = AuthorizationRepository(storage: MemoryStorage())
    }

    func testThatItReturnsNilWithAnEmptyStorage() {
        XCTAssertNil(authorizationRepository.authorization)
    }

    func testThatItReturnsNilWhenSetToNilBefore() {
        authorizationRepository.authorization = .fixture()

        authorizationRepository.authorization = nil

        XCTAssertNil(authorizationRepository.authorization)
    }

    func testThatItReturnsTheAuthorizationThatWasSetBefore() {
        let authorisation = Authorization.fixture()
        authorizationRepository.authorization = authorisation

        XCTAssertEqual(authorisation, authorizationRepository.authorization, "Authorisation obtained from AuthorizationRepository is different than saved into the AuthorizationRepository")
    }
}
