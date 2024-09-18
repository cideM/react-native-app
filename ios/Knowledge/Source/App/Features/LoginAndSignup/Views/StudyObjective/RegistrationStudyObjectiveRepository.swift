//
//  StudyObjectiveRepository.swift
//  Knowledge
//
//  Created by Silvio Bulla on 02.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol StudyObjectiveRepositoryType {
    func getStudyObjectives(completion: @escaping(Result< [StudyObjective], NetworkError<EmptyAPIError>>) -> Void)
    func setStudyObjective(_ studyObjective: StudyObjective, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)
    func getStudyObjective(completion: @escaping (Result<StudyObjective?, NetworkError<EmptyAPIError>>) -> Void)
}

final class RegistrationStudyObjectiveRepository {

    private(set) var studyObjective: StudyObjective? {
        didSet {
            NotificationCenter.default.post(StudyObjectiveDidChangeNotification(oldValue: oldValue, newValue: studyObjective), sender: self)
        }
    }

    private let authenticationClient: AuthenticationClient
    private let userDataRepository: UserDataRepositoryType

    init(authenticationClient: AuthenticationClient = resolve(), userDataRepository: UserDataRepositoryType = resolve()) {
        self.userDataRepository = userDataRepository
        self.authenticationClient = authenticationClient
    }
}

extension RegistrationStudyObjectiveRepository: StudyObjectiveRepositoryType {

    func getStudyObjectives(completion: @escaping (Result<[StudyObjective], NetworkError<EmptyAPIError>>) -> Void) {
        authenticationClient.getRegistrationStudyObjectives { result in
            switch result {
            case .success(let studyObjectives):
                completion(.success(studyObjectives))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setStudyObjective(_ studyObjective: StudyObjective, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        self.studyObjective = studyObjective
        userDataRepository.studyObjective = studyObjective
        completion(.success(()))
    }

    func getStudyObjective(completion: @escaping (Result<StudyObjective?, NetworkError<EmptyAPIError>>) -> Void) {
        completion(.success(userDataRepository.studyObjective))
    }
}
