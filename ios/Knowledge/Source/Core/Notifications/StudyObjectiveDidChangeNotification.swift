//
//  StudyObjectiveDidChangeNotification.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct StudyObjectiveDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: StudyObjective?
    let newValue: StudyObjective?
}
