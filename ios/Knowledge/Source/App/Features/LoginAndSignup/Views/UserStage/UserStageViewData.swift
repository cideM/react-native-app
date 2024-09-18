//
//  UserStageViewData.swift
//  LoginAndSignup
//
//  Created by CSH on 07.10.19.
//  Copyright © 2019 AMBOSS  VSS. All rights reserved.
//

import Domain
import Localization

public struct UserStageViewData {
    let items: [Item]
    let discalimerState: DisclaimerState

    public enum DisclaimerState: Equatable {
        case hidden
        case shown(disclaimer: NSAttributedString, buttonTitle: String)
        case onlyButtonShown(buttonTitle: String)
    }

    public struct Item: Equatable {

        let stage: UserStage
        let title: String
        let shortTitle: String

        var description: String {
            switch stage {
            case .physician: return L10n.UserStage.UserStagePhysician.description
            case .clinic: return L10n.UserStage.UserStageClinic.description
            case .preclinic: return L10n.UserStage.UserStagePreclinic.description
            }
        }

        init(stage: UserStage, title: String, shortTitle: String? = nil) {
            self.stage = stage
            self.title = title
            self.shortTitle = shortTitle ?? title
        }
    }
}

public extension UserStageViewData.Item {
    init(_ stage: UserStage) {
        self.init(stage: stage,
                  title: UserStageViewData.Item.title(for: stage),
                  shortTitle: UserStageViewData.Item.shortTitle(for: stage))
    }

    private static func title(for stage: UserStage) -> String {
        switch stage {
        case .physician: return L10n.UserStage.UserStagePhysician.title
        case .clinic: return L10n.UserStage.UserStageClinic.title
        case .preclinic: return L10n.UserStage.UserStagePreclinic.title
        }
    }

    private static func shortTitle(for stage: UserStage) -> String {
        switch stage {
        case .physician: return L10n.UserStage.UserStagePhysician.title
        case .clinic: return L10n.UserStage.UserStageClinic.title
        case .preclinic: return L10n.UserStage.UserStagePreclinicShort.title
        }
    }
}
