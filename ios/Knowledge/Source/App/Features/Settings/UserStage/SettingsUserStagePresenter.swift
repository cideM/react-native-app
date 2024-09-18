//
//  SettingsUserStagePresenter.swift
//  LoginAndSignup
//
//  Created by CSH on 07.10.19.
//  Copyright © 2019 AMBOSS  VSS. All rights reserved.
//

import Common
import Domain
import Localization

public final class SettingsUserStagePresenter: UserStagePresenterType {

    weak var delegate: UserStagePresenterDelegate?

    private let repository: UserStageRepositoryType
    private let coordinator: UserStageCoordinatorType
    private let userStages: [UserStage]
    private let analyticsTracking: TrackingType
    private var selectedUserStage: UserStage?
    private let referer: Tracker.Event.SignupAndLogin.Referer

    init(repository: UserStageRepositoryType,
         coordinator: UserStageCoordinatorType,
         userStages: [UserStage],
         analyticsTracking: TrackingType = resolve(),
         referer: Tracker.Event.SignupAndLogin.Referer) {
        self.repository = repository
        self.coordinator = coordinator
        self.userStages = userStages
        self.analyticsTracking = analyticsTracking
        self.referer = referer
    }

    public weak var view: UserStageViewType? {
        didSet {
            let items = userStages.map { UserStageViewData.Item($0) }
            view?.setViewData(UserStageViewData(items: items, discalimerState: .hidden))
            analyticsTracking.track(.userStageSelectionShown(referer: referer))
            setViewData()
        }
    }

    public func didSelectUserStage(_ userStage: UserStage) {
        setUserStage(userStage)

        switch userStage {
        case .clinic:
            analyticsTracking.track(.userStageSelected(stage: .clinic, referer: referer))
        case .preclinic:
            analyticsTracking.track(.userStageSelected(stage: .preclinic, referer: referer))
        case .physician:
            analyticsTracking.track(.userStageSelected(stage: .physician, referer: referer))
        }
    }

    private func setUserStage(_ userStage: UserStage) {
        guard selectedUserStage != userStage else { return }

        self.selectedUserStage = userStage
        let visibility = UserStageViewData.DisclaimerState.shown(disclaimer: userStage.agreementMessage, buttonTitle: L10n.Generic.save)
        view?.setDisclaimer(visibility) {}
    }

    private func setViewData() {
        repository.getUserStage { [view] result in
            if let stage = try? result.get() {
                view?.selectUserStage(stage)
            }
        }
    }

    public func agreementTapped(url: URL) {
        coordinator.openURL(url)
    }

    public func primaryButtonTapped() {
        guard let selectedUserStage = selectedUserStage else { return }

        switch selectedUserStage {
        case .clinic:
            analyticsTracking.track(.userStageSubmitted(stage: .clinic, referer: referer))
        case .preclinic:
            analyticsTracking.track(.userStageSubmitted(stage: .preclinic, referer: referer))
        case .physician:
            analyticsTracking.track(.userStageSubmitted(stage: .physician, referer: referer))
        }

        view?.setIsLoading(true)
        repository.setUserStage(selectedUserStage) { [view, setViewData, delegate] result in
            view?.setIsLoading(false)

            switch result {
            case .success:
                view?.setDisclaimer(.hidden) {
                    view?.showSaveNotification()
                    delegate?.didSaveUserStage(selectedUserStage)
                }

            case .failure(let userStageError):
                view?.presentMessage(userStageError)
                setViewData()
            }
        }
    }
}
