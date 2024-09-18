//
//  PharmaPagePresenter.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 04.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import Domain
import Localization
import Combine

protocol PharmaPagePresenterType: DrugListDelegate, PharmaPresenterDelegate, AnyObject {
    var view: PharmaPageViewType? { get set }
    func loadPharmaCard(deeplink: PharmaCardDeeplink)
    func loadPharmaCard(for substanceIdentifier: SubstanceIdentifier, drugIdentifier: DrugIdentifier?)
    func showDisclaimerDialog()
    func didScrollToPage(at index: Int)
    func close()
}

final class PharmaPagePresenter: PharmaPagePresenterType {

    weak var view: PharmaPageViewType? {
        didSet {
            let viewControllers = [pocketCard.view, ifap.view].compactMap { $0 as? PharmaViewController }
            view?.add(viewControllers: viewControllers)
            view?.addCloseButton()
            guard userDataRepository.hasConfirmedHealthCareProfession == true else {
                showDisclaimerDialog()
                return
            }
            if let deeplink {
                loadPharmaCard(for: deeplink.substance, drugIdentifier: deeplink.drug)
            }
        }
    }

    @Inject private var monitor: Monitoring

    private weak var coordinator: PharmaCoordinatorType?
    private let userDataRepository: UserDataRepositoryType
    private var pharmaRepository: PharmaRepositoryType
    private let snippetRepository: SnippetRepositoryType
    private var pharmaCardDeepLink: PharmaCardDeeplink
    private var tracker: PharmaPagePresenter.Tracker

    private let ifap: (presenter: PharmaPresenterType, view: PharmaViewType)
    private let pocketCard: (presenter: PharmaPresenterType, view: PharmaViewType)

    private var deeplink: PharmaCardDeeplink?
    private var pharmaCard: PharmaCard?

    // MARK: - Init

    init(coordinator: PharmaCoordinatorType,
         userDataRepository: UserDataRepositoryType = resolve(),
         pharmaRepository: PharmaRepositoryType = resolve(),
         pharmaCardDeepLink: PharmaCardDeeplink,
         snippetRepository: SnippetRepositoryType,
         tracker: PharmaPagePresenter.Tracker,
         ifap: (presenter: PharmaPresenterType, view: PharmaViewType),
         pocketCard: (presenter: PharmaPresenterType, view: PharmaViewType)) {

        self.coordinator = coordinator
        self.userDataRepository = userDataRepository
        self.pharmaRepository = pharmaRepository
        self.snippetRepository = snippetRepository
        self.pharmaCardDeepLink = pharmaCardDeepLink
        self.tracker = tracker

        self.ifap = ifap
        self.pocketCard = pocketCard

        self.ifap.presenter.delegate = self
        self.pocketCard.presenter.delegate = self

        deeplink = pharmaCardDeepLink
    }

    // MARK: - PharmaPagePresenterType

    func loadPharmaCard(deeplink: PharmaCardDeeplink) {
        self.deeplink = deeplink
        loadPharmaCard(for: deeplink.substance, drugIdentifier: deeplink.drug)
    }

    func loadPharmaCard(for substanceIdentifier: SubstanceIdentifier, drugIdentifier: DrugIdentifier?) {
        self.view?.setIsLoading(true)

        pharmaRepository.pharmaCard(for: substanceIdentifier, drugIdentifier: drugIdentifier, sorting: .mixed, cachePolicy: .reloadIgnoringCacheData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let (pharmaCard, source)):
                let data = CardData(
                    title: pharmaCard.drug.name,
                    identifier: pharmaCard.drug.eid.value,
                    substanceTitle: pharmaCard.substance.name,
                    substanceIdentifier: pharmaCard.substance.id.value,
                    riskInformation: false)
                 self.tracker.source = source
                 self.tracker.fillCardDataOfCard(cardData: data)

                self.pharmaCard = pharmaCard
                view?.setTitle(pharmaCard.substance.name)

                let pharmaViewData = PharmaViewData(substance: pharmaCard.substance, drug: pharmaCard.drug)
                self.ifap.view.setData(for: pharmaViewData)

                let document: SubstanceDocument
                let group = pharmaCard.substance.pocketCard?.groups.first?.anchor
                if
                    let pocketCard = pharmaCard.substance.pocketCard,
                    let data = PharmaViewData(pocketCard: pocketCard) {
                    self.pocketCard.view.setData(for: data)
                    document = .pocketCard
                } else {
                    document = .ifap
                }

                var showsPocketCard: Bool
                var page: PharmaPage

                // Initially set what's visible based on the data delivered via backend ...
                switch document {
                case .pocketCard:
                    showsPocketCard = true
                    page = .pocketCard
                    // self.view?.setShowsPocketCard(true)
                    // self.view?.scrollTo(.pocketCard, animated: true)
                case .ifap:
                    showsPocketCard = false
                    page = .ifap
                    // self.view?.setShowsPocketCard(false)
                    // self.view?.scrollTo(.ifap, animated: false)
                }

                // Modify what's visible in case the deeplink demands otherwise ...
                if let documentFromDeeplink = deeplink?.document {
                    switch documentFromDeeplink {
                    case .ifap(let auxiliaryPresentation):
                        // self.view?.scrollTo(.ifap, animated: false)
                        page = .ifap
                        switch auxiliaryPresentation {
                        case .none: break
                        case .drugSelector: self.shouldShowDrugList()
                        }
                    case .pocketCard(let group, let anchor):
                        if let card = pharmaCard.substance.pocketCard {
                            // This will be nil in case the group does not exist ...
                            if let data = PharmaViewData(pocketCard: card, group: group, pocketCardAnchor: anchor) {
                                self.pocketCard.view.setData(for: data)
                                // ... try again without group anchor
                            } else if let data = PharmaViewData(pocketCard: card) {
                                self.pocketCard.view.setData(for: data)
                            }
                            // self.view?.scrollTo(.pocketCard, animated: true)
                            page = .pocketCard
                        }
                    }
                }

                self.view?.setShowsPocketCard(showsPocketCard)
                self.view?.scrollTo(page, animated: false)

                tracker.trackPharmaAmbossSubstanceOpened(document: document, group: group)

            case .failure(let error):
                self.view?.presentSubviewMessage(error, actions: [
                    MessageAction(title: L10n.Substance.NetworkError.retry, style: .primary) {
                        self.loadPharmaCard(for: substanceIdentifier, drugIdentifier: drugIdentifier)
                        return true
                    },
                    MessageAction(title: L10n.Substance.NetworkError.cancel, style: .normal) {
                        self.coordinator?.stop(animated: true)
                        return true
                    }
                ])
            }
            self.view?.setIsLoading(false)
        }
    }

    func loadDrug(for drugIdentifier: DrugIdentifier) {
        self.view?.setIsLoading(true)
        if let substance = pharmaCard?.substance {
            self.ifap.view.setData(for: PharmaViewData(substance: substance, drug: nil))
        }

        pharmaRepository.drug(for: drugIdentifier, sorting: .mixed) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (drug, source)):
                guard let substance = self.pharmaCard?.substance else { return }

                let data = CardData(
                    title: drug.name,
                    identifier: drug.eid.value,
                    substanceTitle: substance.name,
                    substanceIdentifier: substance.id.value,
                    riskInformation: false)
                 self.tracker.source = source
                 self.tracker.fillCardDataOfCard(cardData: data)

                self.pharmaCard = PharmaCard(substance: substance, drug: drug)
                let pharmaViewData = PharmaViewData(substance: substance, drug: drug)
                self.ifap.view.setData(for: pharmaViewData)

            case .failure(let error):
                self.view?.presentSubviewMessage(error, actions: [
                    MessageAction(title: L10n.Substance.NetworkError.retry, style: .primary) {
                        self.loadDrug(for: drugIdentifier)
                        return true
                    },
                    MessageAction(title: L10n.Substance.NetworkError.cancel, style: .normal) {
                        self.coordinator?.stop(animated: true)
                        return true
                    }
                ])
            }
            self.view?.setIsLoading(false)
        }
    }

    func showDisclaimerDialog() {
        view?.showDisclaimerDialog { [weak self] isConfirmed in
            if isConfirmed {
                self?.userDataRepository.hasConfirmedHealthCareProfession = isConfirmed
                if let deeplink = self?.deeplink {
                    self?.loadPharmaCard(for: deeplink.substance, drugIdentifier: deeplink.drug)
                }
            } else {
                let message = PresentableMessage(title: L10n.Error.Generic.title, description: L10n.Error.Generic.message, logLevel: .info)
                self?.view?.presentSubviewMessage(message, actions: [
                    MessageAction(title: L10n.Generic.retry, style: .primary) {
                        self?.showDisclaimerDialog()
                        return true
                    }
                ])
            }
        }
    }

    func didScrollToPage(at index: Int) {
        switch index {
        case 0: tracker.trackPharmaPageDocumentSelected(document: .pocketCard)
        case 1: tracker.trackPharmaPageDocumentSelected(document: .ifap)
        default: break
        }
    }

    func close() {
        coordinator?.stop(animated: true)
    }
}

// MARK: - PharmaPresenterDelegate

extension PharmaPagePresenter: PharmaPresenterDelegate {

    func shouldShowSnippet(for snippetIdentifier: SnippetIdentifier) {
        view?.setIsLoading(true)
        snippetRepository.snippet(for: snippetIdentifier) { [weak self] result in
            guard let self = self else { return }
            view?.setIsLoading(false)
            switch result {
            case .success(let snippet):
                self.coordinator?.showSnippetView(with: snippet, for: .pharmaCard(self.pharmaCardDeepLink))
            case .failure:
                self.monitor.error("Snippet is not found", context: .none)
            }
        }
    }

    func shouldShowDrugList() {
        coordinator?.showDrugList(for: pharmaCardDeepLink.substance, tracker: tracker, delegate: self)
    }

    func shouldSwitchPocketCardTo(anchor: String) {
        guard let pocketCard = pharmaCard?.substance.pocketCard else { return }
        if let data = PharmaViewData(pocketCard: pocketCard, group: anchor) {
            self.pocketCard.view.setData(for: data)
            tracker.trackPocketCardGroupSelected(group: anchor)
        }
    }

    func shouldShowPricesAndPackageSizes() {
        guard let pharmaCard else {
            assertionFailure("A pharma card should be present at this time")
            return
        }
        self.coordinator?.showPricesAndPackageSizes(data: pharmaCard.drug.pricesAndPackages)
    }
}

extension PharmaPagePresenter: DrugListDelegate {

    func didSelect(drug: DrugIdentifier) {
        loadDrug(for: drug)
    }
}
