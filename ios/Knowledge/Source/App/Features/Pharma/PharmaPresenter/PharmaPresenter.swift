//
//  PharmaPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 21.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import RichTextRenderer
import Localization

/// @mockable
protocol PharmaPresenterDelegate: AnyObject {
    func shouldShowSnippet(for snippetIdentifier: SnippetIdentifier)
    func shouldShowDrugList()
    func shouldSwitchPocketCardTo(anchor: String)
    func shouldShowPricesAndPackageSizes()
}

/// @mockable
protocol PharmaPresenterType: RichTextCellDelegate, PharmaSegmentedControlCellDelegate {
    var view: PharmaViewType? { get set }
    var tracker: PharmaPagePresenter.Tracker? { get set }
    var delegate: PharmaPresenterDelegate? { get set }

    func prescriptionInformationButtonTapped(with prescribingInfoViewData: PharmaPrescribingInfoViewData)
    func patientPackageInsertButtonTapped(with prescribingInfoViewData: PharmaPrescribingInfoViewData)
    func pharmaSectionTapped(section: PharmaViewData.SectionViewData, isExpanded: Bool)
    func sendFeedback()
    func otherPreparationsTapped()
    func viewDidAppear()
    func viewDismissed()
    func showPricesAndPackageSizes()
}

final class PharmaPresenter: PharmaPresenterType {

    weak var view: PharmaViewType?
    weak var delegate: PharmaPresenterDelegate?
    var tracker: PharmaPagePresenter.Tracker?

    private weak var coordinator: PharmaCoordinatorType?
    private var pharmaRepository: PharmaRepositoryType
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let appConfiguration: Configuration
    private let pharmaService: PharmaDatabaseApplicationServiceType?
    private let supportApplicationService: SupportApplicationService

    init(coordinator: PharmaCoordinatorType,
         pharmaRepository: PharmaRepositoryType = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         userDataRepository: UserDataRepositoryType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         pharmaService: PharmaDatabaseApplicationServiceType? = resolve(),
         supportApplicationService: SupportApplicationService = resolve()) {
        self.coordinator = coordinator
        self.pharmaRepository = pharmaRepository
        self.remoteConfigRepository = remoteConfigRepository
        self.userDataRepository = userDataRepository
        self.appConfiguration = appConfiguration
        self.pharmaService = pharmaService
        self.supportApplicationService = supportApplicationService

        supportApplicationService.delegate = self
    }

    private func showSnippet(for snippetIdentifier: SnippetIdentifier) {
        delegate?.shouldShowSnippet(for: snippetIdentifier)
    }

    func sendFeedback() {
        coordinator?.sendFeedback()
        tracker?.trackPharmaFeedbackOpened()
    }

    private func showDrugList() {
        delegate?.shouldShowDrugList()
    }

    func otherPreparationsTapped() {
        delegate?.shouldShowDrugList()
        tracker?.trackAvailableDrugsOpened()
    }

    func prescriptionInformationButtonTapped(with prescribingInfoViewData: PharmaPrescribingInfoViewData) {
        guard let prescribingInformationUrl = prescribingInfoViewData.prescribingInformationUrl else { return }
        openPDF(prescribingInformationUrl, title: L10n.Substance.prescribingInformationLabel)
    }

    func patientPackageInsertButtonTapped(with prescribingInfoViewData: PharmaPrescribingInfoViewData) {
        guard let patientPackageInsertUrl = prescribingInfoViewData.patientPackageInsertUrl else { return }
        openPDF(patientPackageInsertUrl, title: L10n.Substance.patientPackageLabel)
    }

    private func openPDF(_ url: URL, title: String) {
        coordinator?.openPDF(with: url, title: title)
        tracker?.trackFileOpen(document: title)
    }

    func openURLInternally(_ url: URL) {
        coordinator?.openURLInternally(url)
    }

    func openURLExternally(_ url: URL) {
        coordinator?.openURLExternally(url)
    }

    func pharmaSectionTapped(section: PharmaViewData.SectionViewData, isExpanded: Bool) {
        tracker?.trackSectionToggled(section: section, isExpanded: isExpanded)
    }

    func showPricesAndPackageSizes() {
        delegate?.shouldShowPricesAndPackageSizes()
    }

    func viewDidAppear() {
        // Offer installation of pharma offline db in case pharma screen was presented often enough
        // Wait a bit before presenting the dialog, it looks odd if the UI and the alert come up at the same time ...
        if let view = self.view, let pharmaService = self.pharmaService {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: self.pharmaRepository)
            }
        }
    }

    func viewDismissed() {
        tracker?.trackPharmaCardClose()
    }
}

extension PharmaPresenter: RichTextCellDelegate {
    func didTapHyperlink(url: URL) {
        coordinator?.openURLInternally(url)
    }

    func didTapPharmaRichTextLink(phrasionary: Phrasionary.Data?, ambossLink: AmbossLink.Data?) {

        if let phraseGroupId = phrasionary?.phraseGroupEid, let snippetIdentifier = SnippetIdentifier(phraseGroupId) {
            showSnippet(for: snippetIdentifier)
        } else if
            let ambossLink = ambossLink,
            let id = ambossLink.articleEid,
            let articleId = LearningCardIdentifier(id),
            let anchor = ambossLink.anchor {
              let learningCardDeeplink = LearningCardDeeplink(
                learningCard: articleId,
                anchor: LearningCardAnchorIdentifier(anchor),
                particle: nil,
                sourceAnchor: nil)
            coordinator?.navigate(to: learningCardDeeplink)
            tracker?.trackArticleSelected(articleId: learningCardDeeplink.learningCard)

        } else if let string = ambossLink?.uri, let url = URL(string: string) {
              coordinator?.openURLInternally(url)
        }
    }
}

extension PharmaPresenter: SupportApplicationServiceDelegate {
    func feedbackSubmitted(feedbackText: String) {
        tracker?.trackPharmaFeedbackSubmitted(feedbackText: feedbackText)
    }
}

extension PharmaPresenter: PharmaSegmentedControlCellDelegate {
    func didSelect(anchor: String) {
        delegate?.shouldSwitchPocketCardTo(anchor: anchor)
    }
}
