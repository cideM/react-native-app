//
//  AboutPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

protocol AboutPresenterType: AnyObject {
    var view: AboutViewType? { get set }
    func didSelect(item: AboutViewItem)
}

final class AboutPresenter: AboutPresenterType {

    private let coordinator: SettingsCoordinatorType
    private let consentApplicationService: ConsentApplicationServiceType

    weak var view: AboutViewType? {
        didSet {
            view?.setData(viewData())
        }
    }

    init(coordinator: SettingsCoordinatorType, consentApplicationService: ConsentApplicationServiceType = resolve()) {
        self.coordinator = coordinator
        self.consentApplicationService = consentApplicationService
    }

    private func viewData() -> [AboutViewItem] {
        let items = [
            AboutViewItem(type: .privacy),
            AboutViewItem(type: .terms),
            AboutViewItem(type: .legal),
            AboutViewItem(type: .consentManagement),
            AboutViewItem(type: .libraries)
        ]
        return items
    }

    func didSelect(item: AboutViewItem) {
        let configuration: URLConfiguration = AppConfiguration.shared

        switch item.type {
        case .legal:
            coordinator.openInApp(configuration.legalNoticeURL)
        case .privacy:
            coordinator.openInApp(configuration.privacyURL)
        case .consentManagement:
            consentApplicationService.showConsentSettings()
        case .libraries:
            coordinator.openLibrariesView()
        case .terms:
            coordinator.openInApp(configuration.termsAndConditionsURL)
        }
    }
}
