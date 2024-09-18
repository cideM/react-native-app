//
//  DrugListPresenter.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 08.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

final class DrugListPresenter: DrugListPresenterType {

    private let coordinator: PharmaCoordinatorType
    private let pharmaRepository: PharmaRepositoryType
    private let substanceIdentifier: SubstanceIdentifier
    private let tracker: PharmaPagePresenter.Tracker?

    weak var delegate: DrugListDelegate?

    weak var view: DrugListViewType? {
        didSet {
            loadDrugListData(for: substanceIdentifier)
        }
    }

    private var cachedDrugs: [DrugReference]?

    init(coordinator: PharmaCoordinatorType, pharmaRepository: PharmaRepositoryType, substanceIdentifier: SubstanceIdentifier, tracker: PharmaPagePresenter.Tracker?, delegate: DrugListDelegate?) {
        self.coordinator = coordinator
        self.substanceIdentifier = substanceIdentifier
        self.pharmaRepository = pharmaRepository
        self.tracker = tracker
        self.delegate = delegate
    }

    func searchTriggered(with query: String, applicationForm: ApplicationForm) {
        guard let cachedDrugs = cachedDrugs else {
            assertionFailure("There should be cached drugs available at this point")
            return
        }

        let drugs = viewData(for: cachedDrugs, with: query, and: applicationForm)
        self.view?.updateDrugList(drugs: drugs)
        self.tracker?.trackAvailableDrugsFiltered(query: query, results: drugs.map {
            PharmaFilterResult(id: $0.id.value, title: $0.name, subtitle: $0.vendor)
        })
    }

    func navigate(to drug: DrugIdentifier, title: String) {
        tracker?.trackPharmaDrugsListClosed()
        tracker?.trackAvailableDrugsSelected(drugTitle: title, drugId: drug.value)
        coordinator.dismissDrugList { [weak self] in
            self?.delegate?.didSelect(drug: drug)
        }
    }

    private func loadDrugListData(for substanceIdentifier: SubstanceIdentifier, query: String = "", applicationForm: ApplicationForm = .all) {
        view?.showIsLoading(true)
        self.pharmaRepository.substance(for: substanceIdentifier) { [weak self] result in
            guard let self = self else { return }
            self.view?.showIsLoading(false)

            switch result {
            case .success((let agent, _)):
                self.cachedDrugs = agent.drugReferences
                let drugs = self.viewData(for: agent.drugReferences, with: query, and: applicationForm)
                self.view?.updateDrugList(drugs: drugs)
                self.tracker?.trackAvailableDrugsFiltered(query: query, results: drugs.map {
                    PharmaFilterResult(id: $0.id.value, title: $0.name, subtitle: $0.vendor)
                })

                var data = [TagButton.ViewData]()
                // Count through application forms for all available drugs for this agent ...
                var drugsAndApplicationForms = [ApplicationForm: [DrugReference]]()
                for drug in agent.drugReferences {
                    for applicationForm in drug.applicationForms {
                        if drugsAndApplicationForms[applicationForm] == nil {
                            drugsAndApplicationForms[applicationForm] = [drug]
                        } else {
                            drugsAndApplicationForms[applicationForm]?.append(drug)
                        }
                    }
                }
                // Insert `ApplicationForm.all` on the DrugList filter.
                if  agent.applicationForms.count > 1 {
                    let count = drugsAndApplicationForms.reduce(into: 0) { total, element in total += element.value.count }
                    data.insert(.init(count: count, applicationForm: .all), at: 0)
                }
                // Map resulting counts into "view data" object ...
                let countedApplicationForms = drugsAndApplicationForms.map({ applicatinForm, drugs in
                    TagButton.ViewData(count: drugs.count, applicationForm: applicatinForm)
                })
                data += countedApplicationForms
                // And finally sort by first letter ...
                let sortedData = data.sorted { $0.applicationForm.order < $1.applicationForm.order }

                self.view?.setApplicationForms(sortedData)

            case .failure:
                self.view?.showIsLoading(false)
                assertionFailure("Agent is not found.")
            }
        }
    }

    /// Fiters `DrugRefereces` list by `query` and `ApplicationForm`.
    /// - Parameters:
    ///   - query: The query we are interested in filtering.
    ///   - applicationForm: The applicationForm we are interested in filtering.
    ///   - list: DrugReference list we need to filter.
    /// - Returns: Filtered DrugReference list.
    private func filteredDrugList(query: String, applicationForm: ApplicationForm, list: [DrugReference]) -> [DrugReference] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        let fragments = query
            .components(separatedBy: .whitespaces)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } // -> Remove "whitespace only" chunks

        let filteredDrugsByQuery = list.filter {  drug -> Bool in
            fragments.allSatisfy {
                drug.name.localizedCaseInsensitiveContains($0) || drug.vendor?.localizedCaseInsensitiveContains($0) ?? false
            }
        }

        guard applicationForm != .all else { return filteredDrugsByQuery }

        let drugReferencesFilteredByQueryAndApplicationForm = filteredDrugsByQuery.filter {
            $0.applicationForms.contains(applicationForm)
        }

        return drugReferencesFilteredByQueryAndApplicationForm
    }

    private func viewData(for drugs: [DrugReference], with query: String, and applicationForm: ApplicationForm) -> [DrugReferenceViewData] {
        let filteredDrugList = self.filteredDrugList(query: query, applicationForm: applicationForm, list: drugs)
        let drugs = filteredDrugList.map { DrugReferenceViewData(drugReference: $0) }
        return drugs
    }
}
