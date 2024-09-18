//
//  ExtensionTests.swift
//  KnowledgeTests
//
//  Created by Cornelius Horstmann on 27.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import XCTest

class ExtensionTests: XCTestCase {

    func testUnformattedNote() {
        XCTAssertEqual(Extension.fixture(note: "&nbsp;").unformattedNote, " ")
        XCTAssertEqual(Extension.fixture(note: "Text&nbsp;<b><p><i></br><br /></p><b/> <b>bold</b>,1 < 2 > 0").unformattedNote, "Text  bold,1 < 2 > 0")
    }

    func testSynchonousUnformatting() {
        for _ in 0..<1000 {
            let e = Extension.fixture(note: "Text&nbsp;<b><p><i></br><br /></p><b/> <b>bold</b>,1 < 2 > 0")
            DispatchQueue.main.async {
                _ = e.unformattedNote
            }
        }
    }
}
