//
//  Tracker.Event.Search.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 21.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

extension Tracker.Event {
    enum Payload {
        case standard(userID: String?, stage: UserStage?, studyObjective: StudyObjective?, libraryVersion: Int?, region: String)
    }
}
