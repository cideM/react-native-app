//
//  UserStagePresenterType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

public protocol UserStagePresenterType {
    var view: UserStageViewType? { get set }

    func didSelectUserStage(_ userStage: UserStage)
    func agreementTapped(url: URL)
    func primaryButtonTapped()
}

public protocol UserStagePresenterDelegate: AnyObject {

    func didSaveUserStage(_ stage: UserStage)
}
