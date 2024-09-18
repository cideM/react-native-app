//
//  SegmentTrackingSerializer+UserProperty.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 30.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func parameters(for property: Tracker.UserTraits) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.UserProperty>()
        switch property {
        case .user(let user):
            parameters.set(user?.identifier.description, for: .userID)
        case .deviceId: break
        case .stage(let stage):
            parameters.set(stage, for: .userStage)
        case .studyObjective(let studyObjective):
            parameters.set(studyObjective?.name, for: .studyObjective)
        case .libraryMetadata(let library):
            parameters.set(library?.versionId, for: .libraryVersion)
        case .variant(let variant):
            parameters.set(value(for: variant), for: .region)
        case .features(let features):
            parameters.set(features, for: .features)
        }
        return parameters.data
    }

    private func value(for variant: AppVariant) -> String {
        switch variant {
        case .knowledge: return "us"
        case .wissen: return "eu"
        }
    }
}

extension SegmentParameter {
    enum UserProperty: String {
        case userID = "user_id"
        case userStage = "user_stage"
        case studyObjective = "study_objective"
        case libraryVersion = "library_version"
        case region
        case features
    }
}
