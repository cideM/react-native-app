//
//  UserDataRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 19.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol UserDataRepositoryType: AnyObject {
    var userStage: UserStage? { get set }
    var studyObjective: StudyObjective? { get set }
    /// Indicates that the current user has confirmed the "Bestätigung Heilberufe" or not.
    var hasConfirmedHealthCareProfession: Bool? { get set }
    var shouldUpdateTerms: Bool { get set }
    func removeAllDataFromLocalStorage()
}

final class UserDataRepository: UserDataRepositoryType {

    var userStage: UserStage? {
        get {
            guard let rawValue: String = storage.get(for: .userStage) else { return nil }
            return UserStage(rawValue: rawValue)
        }
        set {
            guard newValue != userStage else { return }
            let oldValue = userStage
            storage.store(newValue?.rawValue, for: .userStage)
            NotificationCenter.default.post(UserStageDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var studyObjective: StudyObjective? {
        get {
            storage.get(for: .studyObjective)
        }
        set {
            guard newValue != studyObjective else { return }
            let oldValue = studyObjective
            storage.store(newValue, for: .studyObjective)
            NotificationCenter.default.post(StudyObjectiveDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var hasConfirmedHealthCareProfession: Bool? {
        get {
            storage.get(for: .hasConfirmedHealthCareProfession)
        }
        set {
            guard newValue != hasConfirmedHealthCareProfession else { return }
            storage.store(newValue, for: .hasConfirmedHealthCareProfession)
            if let newValue = newValue {
                NotificationCenter.default.post(ProfessionConfirmationDidChangeNotification(oldValue: nil, newValue: newValue), sender: self)
            }
        }
    }

    var shouldUpdateTerms: Bool {
        get {
            storage.get(for: .shouldUpdateTerms) ?? false
        }
        set {
            let oldValue = shouldUpdateTerms
            storage.store(newValue, for: .shouldUpdateTerms)
            // This needs to be sent always cause we act on as long as it's "true"
            NotificationCenter.default.post(TermsComplianceRequiredNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    func removeAllDataFromLocalStorage() {
        userStage = nil
        studyObjective = nil
        hasConfirmedHealthCareProfession = nil
    }
}
