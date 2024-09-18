//
//  AppearancePresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 07.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

protocol AppearanceSettingsPresenterType: AnyObject {
    var view: AppearanceSettingsTableViewType? { get set }

    func keepScreenActiveDidChange(isEnabled: Bool)
    func userInterfaceStyleDidChange(style: UIUserInterfaceStyle)
}

final class AppearanceSettingsPresenter: AppearanceSettingsPresenterType {

    weak var view: AppearanceSettingsTableViewType? {
        didSet {
            view?.setSections(createSections())
        }
    }

    private let repository: DeviceSettingsRepositoryType
    private let appearanceService: AppearanceApplicationServiceType
    private let tracker: TrackingType

    init(repository: DeviceSettingsRepositoryType = resolve(),
         appearanceService: AppearanceApplicationServiceType = resolve(),
         tracker: TrackingType = resolve()) {
        self.repository = repository
        self.appearanceService = appearanceService
        self.tracker = tracker
    }

    func keepScreenActiveDidChange(isEnabled: Bool) {
        repository.keepScreenOn = isEnabled
        trackKeepScreenActiveToggleed()
    }

    func createSections() -> [AppearanceSettingsSection] {
        var sections = [AppearanceSettingsSection]()
        if appearanceService.userCanChangeInterfaceStyle {
            sections.append(.theme(style: repository.currentUserInterfaceStyle))
        }
        sections.append(.keepScreenOn(isEnabled: repository.keepScreenOn))
        return sections
    }

    func userInterfaceStyleDidChange(style: UIUserInterfaceStyle) {
        repository.currentUserInterfaceStyle = style

        view?.setSections(createSections())
        trackAppearanceSettingsUpdated()
    }

    func trackKeepScreenActiveToggleed() {
        let value = repository.keepScreenOn
        tracker.track(.settingsKeepScreenActiveToggled(newValue: value))
    }

    func trackAppearanceSettingsUpdated() {
        let appearancePreference = repository.currentUserInterfaceStyle.trackingPreference()
        let systemAppearancePreference = UIScreen.main.traitCollection.userInterfaceStyle.trackingSystemPreference()
        tracker.track(.settingsAppearancePreferenceUpdated(
            appearancePreference: appearancePreference,
            systemAppearancePreference: systemAppearancePreference))
    }
}

enum AppearanceSettingsSection {
    case keepScreenOn(isEnabled: Bool)
    case theme(style: UIUserInterfaceStyle)
}
