//
//  DrugListPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 25.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class DrugListPresenterTests: XCTestCase {

    var presenter: DrugListPresenterType!
    var pharmaRepository: PharmaRepositoryTypeMock!
    var view: DrugListViewTypeMock!
    var coordinator: PharmaCoordinatorTypeMock!
    var drugListDelegate: DrugListDelegateMock!
    let substanceIdentifier: SubstanceIdentifier = .fixture()

    override func setUp() {
        view = DrugListViewTypeMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        drugListDelegate = DrugListDelegateMock()
        coordinator = PharmaCoordinatorTypeMock()
        presenter = DrugListPresenter(coordinator: coordinator, pharmaRepository: pharmaRepository, substanceIdentifier: substanceIdentifier, tracker: nil, delegate: drugListDelegate)
    }

    func testThatSettingTheViewLoadsDrugListAndSetsTheCorrectDrugsOnTheView() {
        let drugs: [DrugReference] = .fixture()

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugs)
            completion(.success((agent, Metrics.Source.online)))
        }

        let exp = expectation(description: "updateDrugList was called on the view")
        view.updateDrugListHandler = { resultDrugs in
            XCTAssertEqual(drugs.map(DrugReferenceViewData.init), resultDrugs)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatCallingNavigateToTellsTheDelegateToChangeTheSelectedDrug() {
        let targetDrugIdentifier: DrugIdentifier = .fixture()
        let exp = expectation(description: "Completion was called")

        drugListDelegate.didSelectHandler = { drug in
            XCTAssertEqual(targetDrugIdentifier, drug)
            exp.fulfill()
        }
        coordinator.dismissDrugListHandler = {
            $0?()
        }
        
        presenter.navigate(to: targetDrugIdentifier, title: .fixture())
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAChangeInTheSearchTextFieldsReturnsCorrectDataAfterFilteringForTwoFragments() {
        let query: String = "RA 10mg"

        let drugReferences: [DrugReference] = [
            .fixture(name: "De 2.5mg T"),
            .fixture(name: "De 5mg T"),
            .fixture(name: "Ra 2.5mg T"),
            .fixture(name: "Ra 10mg T")
        ]

        let exp = expectation(description: "drugReferences was called")
        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateExp = expectation(description: "Update drug list called")
        view.updateDrugListHandler = { _ in
            updateExp.fulfill()
        }

        presenter.view = view
        wait(for: [exp, updateExp], timeout: 0.1)

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateFilteredExp = expectation(description: "Update drug list after filtering called")
        view.updateDrugListHandler = { drugList in
            XCTAssertEqual(drugList.count, 1)
            XCTAssertEqual(drugList[0].name, "Ra 10mg T")
            updateFilteredExp.fulfill()
        }

        presenter.searchTriggered(with: query, applicationForm: .all)
        wait(for: [updateFilteredExp], timeout: 0.1)
    }

    func testThatAChangeInTheSearchTextFieldsReturnsCorrectDataAfterApplicationFormFiltering() {
        let applicationForms: [ApplicationForm] = [.bronchial]

        let drugReferences: [DrugReference] = [
            .fixture(name: "De 2.5mg T", applicationForms: applicationForms),
            .fixture(name: "De 5mg T"),
            .fixture(name: "Ra 2.5mg T"),
            .fixture(name: "Ra 10mg T")
        ]

        let exp = expectation(description: "drugReferences was called")
        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }
        let updateExp = expectation(description: "Update drug list called")
        view.updateDrugListHandler = { _ in
            updateExp.fulfill()
        }

        presenter.view = view
        wait(for: [exp, updateExp], timeout: 1)

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateFilteredExp = expectation(description: "Update drug list after filtering called")
        view.updateDrugListHandler = { drugList in
            XCTAssertEqual(drugList.count, 1)
            for applicationForm in applicationForms {
                XCTAssertTrue(drugList[0].applicationForms.contains(applicationForm.name))
            }
            updateFilteredExp.fulfill()
        }

        presenter.searchTriggered(with: "", applicationForm: applicationForms[0])

        wait(for: [updateFilteredExp], timeout: 0.1)
    }

    func testThatAChangeInTheSearchTextFieldsReturnsCorrectDataAfterQueryAndApplicationFormFiltering() {
        let query: String = "mg"
        let applicationForms: [ApplicationForm] = [.bronchial]

        let drugReferences: [DrugReference] = [
            .fixture(name: "De 2.5mg T", applicationForms: applicationForms),
            .fixture(name: "De 5mg T", applicationForms: []),
            .fixture(name: "Ra 2.5mg T", applicationForms: applicationForms),
            .fixture(name: "Ra 10mg T", applicationForms: [])
        ]
        let exp = expectation(description: "drugReferences was called")
        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateExp = expectation(description: "Update drug list called")
        view.updateDrugListHandler = { _ in
            updateExp.fulfill()
        }

        presenter.view = view
        wait(for: [exp, updateExp], timeout: 0.1)

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateFilteredExp = expectation(description: "Update drug list after filtering called")
        view.updateDrugListHandler = { drugList in
            XCTAssertEqual(drugList.count, 2)
            for drug in drugList {
                for applicationForm in applicationForms {
                    XCTAssertTrue(drug.applicationForms.contains(applicationForm.name))
                }
            }
            updateFilteredExp.fulfill()
        }

        presenter.searchTriggered(with: query, applicationForm: applicationForms[0])

        wait(for: [updateFilteredExp], timeout: 0.1)
    }

    func testThatAfterQueryingBy_All_ApplicationFormAllDrugReferencesAreReturned() {
        let query: String = "mg"
        let applicationForms: [ApplicationForm] = [.all]

        let drugReferences: [DrugReference] = [
            .fixture(name: "De 2.5mg T", applicationForms: [.fixture()]),
            .fixture(name: "De 5mg T", applicationForms: [.fixture()]),
            .fixture(name: "Ra 2.5mg T", applicationForms: [.bronchial]),
            .fixture(name: "Ra 10mg T", applicationForms: [.other])
        ]
        let exp = expectation(description: "drugReferences was called")
        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateExp = expectation(description: "Update drug list called")
        view.updateDrugListHandler = { _ in
            updateExp.fulfill()
        }

        presenter.view = view
        wait(for: [exp, updateExp], timeout: 0.1)

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateFilteredExp = expectation(description: "Update drug list after filtering called")
        view.updateDrugListHandler = { drugList in
            XCTAssertEqual(drugList.count, 4)
            updateFilteredExp.fulfill()
        }

        presenter.searchTriggered(with: query, applicationForm: applicationForms[0])

        wait(for: [updateFilteredExp], timeout: 0.1)
    }

    func testThatSettingTheViewLoadsApplicationFormsAndSetsThemOnTheView() {
        let applicationForms: [ApplicationForm] = [.bronchial, .enteral]
        let drugs: [DrugReference] = [DrugReference.fixture(applicationForms: applicationForms)]

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugs)
            completion(.success((agent, Metrics.Source.online)))
        }

        let exp = expectation(description: "setApplicationForms was called on the view")
        view.setApplicationFormsHandler = { data in
            // It should also contain `.all` if there are more than 1 application form.
            XCTAssert(data.contains(where: { $0.applicationForm == .all }))
            XCTAssertEqual(data.count, 3)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatIfThereIsOnlyOneApplicationFormTheAllApplicationFormIsNotInserted() {
        let applicationForms: [ApplicationForm] = [.bronchial]
        let drugs: [DrugReference] = [DrugReference.fixture(applicationForms: applicationForms)]

        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugs)
            completion(.success((agent, Metrics.Source.online)))
        }

        let exp = expectation(description: "setApplicationForms was called on the view")
        view.setApplicationFormsHandler = { data in
            XCTAssertFalse(data.contains(where: { $0.applicationForm == .all }))
            XCTAssertEqual(data.count, 1)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatSearchingByVendorNameReturnsTheCorrectResults() {

        let query: String = "Some"

        let drugReferences: [DrugReference] = [
            .fixture(name: "De 2.5mg T", vendor: query),
            .fixture(name: "De 5mg T"),
            .fixture(name: "Ra 2.5mg T", vendor: "Some GmbH"),
            .fixture(name: "Ra 10mg T")
        ]

        let exp = expectation(description: "drugReferences was called")
        pharmaRepository.substanceHandler = { _, _, completion in
            let agent = Substance.fixture(drugReferences: drugReferences)
            completion(.success((agent, Metrics.Source.online)))
            exp.fulfill()
        }

        let updateExp = expectation(description: "Update drug list called")
        updateExp.expectedFulfillmentCount = 2
        view.updateDrugListHandler = { drugList in
            print(self.view.updateDrugListCallCount)
            switch self.view.updateDrugListCallCount {
            case 1: // Initial data ...
                XCTAssertEqual(drugList.count, 4)
                updateExp.fulfill()
            case 2: // Data after filtering ...
                XCTAssertEqual(drugList.count, 2)
                updateExp.fulfill()
            default:
                XCTFail()
            }
        }

        presenter.view = view
        self.presenter.searchTriggered(with: query, applicationForm: .all)
        wait(for: [exp, updateExp], timeout: 0.1)
    }
}
