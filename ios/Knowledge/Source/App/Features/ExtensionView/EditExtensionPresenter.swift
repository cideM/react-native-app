//
//  ExtensionPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 09.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

protocol EditExtensionPresenterType {
    var view: EditExtensionViewType? { get set }
    func saveExtension(with note: String)
    func cancelChanges(with note: String)
    func openURL(_ url: URL)
}

final class EditExtensionPresenter: EditExtensionPresenterType {

    weak var view: EditExtensionViewType? {
        didSet {
            guard let ext = extensionRepository.extensionForSection(learningCardSectionIdentifier) else { return }
            view?.setExtensionText(extensionContent: ext.note)
        }
    }

    private let extensionRepository: ExtensionRepositoryType
    private let learningCardSectionIdentifier: LearningCardSectionIdentifier
    private let learningCard: LearningCardIdentifier
    private let coordinator: LearningCardCoordinatorType

    init(extensionRepository: ExtensionRepositoryType = resolve(), learningCard: LearningCardIdentifier, learningCardSectionIdentifier: LearningCardSectionIdentifier, coordinator: LearningCardCoordinatorType) {
        self.extensionRepository = extensionRepository
        self.learningCard = learningCard
        self.learningCardSectionIdentifier = learningCardSectionIdentifier
        self.coordinator = coordinator
    }

    func saveExtension(with note: String) {
        let currentExtension = extensionRepository.extensionForSection(learningCardSectionIdentifier)
        let newExtension = Extension(learningCard: learningCard, section: learningCardSectionIdentifier, updatedAt: Date(), previousUpdatedAt: currentExtension?.previousUpdatedAt, note: note)
        extensionRepository.set(ext: newExtension)

        coordinator.dismissExtensionView()
    }

    func cancelChanges(with note: String) {
        let message = PresentableMessage(title: L10n.Note.Alert.leavePageConfirmationTitle, description: L10n.Note.Alert.leavePageConfirmationMessage, logLevel: .info)
        let yesAction = MessageAction(title: L10n.Generic.yes, style: .normal) { [weak self] in
            self?.coordinator.dismissExtensionView()
            return true
        }
        let noAction = MessageAction(title: L10n.Generic.no, style: .primary, handlesError: false)

        let existingNote = extensionRepository.extensionForSection(learningCardSectionIdentifier)?.note ?? ""
        if note == existingNote {
            coordinator.dismissExtensionView()
        } else {
            view?.presentMessage(message, actions: [yesAction, noAction])
        }
    }

    func openURL(_ url: URL) {
        coordinator.openURLExternally(url)
    }
}
