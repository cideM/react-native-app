//
//  EditExtensionPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class EditExtensionPresenterTests: XCTestCase {

    var presenter: EditExtensionPresenterType!
    var learningCardCoordinator: LearningCardCoordinatorTypeMock!
    var extensionsRepository: ExtensionRepositoryTypeMock!
    var learningCardSectionIdentifier: LearningCardSectionIdentifier!
    var learningCard: LearningCardIdentifier!

    override func setUp() {
        learningCardSectionIdentifier = .some(.fixture())
        extensionsRepository = ExtensionRepositoryTypeMock()
        learningCardCoordinator = LearningCardCoordinatorTypeMock()
        learningCard = .some(.fixture(value: "spec_1"))

        presenter = EditExtensionPresenter(extensionRepository: extensionsRepository, learningCard: learningCard, learningCardSectionIdentifier: learningCardSectionIdentifier, coordinator: learningCardCoordinator)
    }

    func testThatNotesAreStoredInTheRepository() {
        let newExtension: Extension = .fixture(learningCard: learningCard, section: learningCardSectionIdentifier)

        extensionsRepository.setHandler = { savedExtension in
            XCTAssertEqual(newExtension.note, savedExtension.note)
            XCTAssertEqual(newExtension.section, savedExtension.section)
        }

        presenter.saveExtension(with: newExtension.note)

        XCTAssertEqual(extensionsRepository.setCallCount, 1)
    }

    func testThatAnExistingPreviousUpdatedAtIsPreserved() {
        let existingExtension: Extension = .fixture(previousUpdatedAt: Date())
        extensionsRepository.extensionForSectionHandler = { _ in
            existingExtension
        }

        extensionsRepository.setHandler = { ext in
            XCTAssertEqual(ext.previousUpdatedAt, existingExtension.previousUpdatedAt)
        }

        presenter.saveExtension(with: "new note")
    }

    func testThatPreviousUpdatedIsNilIfItWasNil() {
        let existingExtension: Extension = .fixture(previousUpdatedAt: nil)
        extensionsRepository.extensionForSectionHandler = { _ in
            existingExtension
        }

        extensionsRepository.setHandler = { ext in
            XCTAssertEqual(ext.previousUpdatedAt, nil)
        }

        presenter.saveExtension(with: "new note")
    }

    func testThatAnPreviousUpdatedAtIsNilForANonExistingNote() {
        extensionsRepository.extensionForSectionHandler = { _ in
            nil
        }

        extensionsRepository.setHandler = { ext in
            XCTAssertEqual(ext.previousUpdatedAt, nil)
        }

        presenter.saveExtension(with: "new note")
    }

    func testThatCancelShowsAnAlertIfTheNoteWasModified() {
        extensionsRepository.extensionForSectionHandler = { _ in
            .fixture(note: "old note")
        }
        let view = EditExtensionViewTypeMock()
        presenter.view = view

        presenter.cancelChanges(with: "new note")

        XCTAssertTrue(view.presentMessageCallCount == 1)
        XCTAssertTrue(learningCardCoordinator.dismissExtensionViewCallCount == 0)
    }

    func testThatCancelDoesntShowAnAlertIfTheNoteWasNotModified() {
        extensionsRepository.extensionForSectionHandler = { _ in
            .fixture(note: "old note")
        }
        let view = EditExtensionViewTypeMock()
        presenter.view = view

        presenter.cancelChanges(with: "old note")

        XCTAssertTrue(view.presentMessageCallCount == 0)
        XCTAssertTrue(learningCardCoordinator.dismissExtensionViewCallCount == 1)
    }

    func testThatCancelShowsAnAlertIfThereWasNoNoteBefore() {
        extensionsRepository.extensionForSectionHandler = { _ in
            nil
        }
        let view = EditExtensionViewTypeMock()
        presenter.view = view

        presenter.cancelChanges(with: "new note")

        XCTAssertTrue(view.presentMessageCallCount == 1)
        XCTAssertTrue(learningCardCoordinator.dismissExtensionViewCallCount == 0)
    }

    func testThatCancelDoesntShowAnAlertIfThereWasNoNoteBeforeAndTheNewNoteIsEmpty() {
        extensionsRepository.extensionForSectionHandler = { _ in
            nil
        }
        let view = EditExtensionViewTypeMock()
        presenter.view = view

        presenter.cancelChanges(with: "")

        XCTAssertTrue(view.presentMessageCallCount == 0)
        XCTAssertTrue(learningCardCoordinator.dismissExtensionViewCallCount == 1)
    }

    func testThatTheViewIsInitializedWithTheCorrectNote() {
        extensionsRepository.extensionForSectionHandler = { _ in
            .fixture(note: "correct note")
        }

        let view = EditExtensionViewTypeMock()
        view.setExtensionTextHandler = {
            XCTAssertEqual($0, "correct note")
        }

        presenter.view = view
        XCTAssertEqual(view.setExtensionTextCallCount, 1)
    }

}
