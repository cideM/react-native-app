//
//  ShortcutsRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 20.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class ShortcutsRepositoryTests: XCTestCase {
    var storage: Storage!
    var shortcutsRepository: ShortcutsRepositoryType!

    override func setUp() {
        storage = MemoryStorage()
        shortcutsRepository = ShortcutsRepository(storage: storage)
    }

    func testThatCalling_IncreaseUsageCountForAShortcut_UpdatesTheStorageForIt() {
        storage.store(nil as Int?, for: .searchUsageCount)

        shortcutsRepository.increaseUsageCount(for: .search)

        let searchUsageCount: Int? = storage.get(for: .searchUsageCount)
        XCTAssertEqual(searchUsageCount, 1)
    }

    func testThatCalling_ShouldOfferAddingVoiceShortcutForAShortcutThatIsNotElligibleYet_ReturnsFalse() {
        storage.store(3 as Int?, for: .searchUsageCount)
        storage.store(nil as Bool?, for: .addingVoiceShortcutForSearchWasOffered)

        XCTAssertFalse(shortcutsRepository.shouldOfferAddingVoiceShortcut(for: .search))
    }

    func testThatCalling_ShouldOfferAddingVoiceShortcutForAShortcutThatIsElligibleYet_ReturnsTrue() {
        storage.store(10 as Int?, for: .searchUsageCount)
        storage.store(nil as Bool?, for: .addingVoiceShortcutForSearchWasOffered)

        XCTAssertTrue(shortcutsRepository.shouldOfferAddingVoiceShortcut(for: .search))
    }

    func testThatCalling_ShouldOfferAddingVoiceShortcutForAShortcutThatIsElligibleButHasBeenOfferedBefore_ReturnsFalse() {
        storage.store(3 as Int?, for: .searchUsageCount)
        storage.store(true, for: .addingVoiceShortcutForSearchWasOffered)

        XCTAssertFalse(shortcutsRepository.shouldOfferAddingVoiceShortcut(for: .search))
    }

    func testThatCalling_AddVoiceShortcutWasOfferedForAShortcut_UpdatesTheStorageForThatShortcut() {
        storage.store(nil as Bool?, for: .addingVoiceShortcutForSearchWasOffered)

        shortcutsRepository.addingVoiceShortcutWasOffered(for: .search)

        let addVoiceShortcutWasOffered: Bool? = storage.get(for: .addingVoiceShortcutForSearchWasOffered)
        XCTAssertTrue(addVoiceShortcutWasOffered!)
    }
}
