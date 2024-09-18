//
//  CombinedClient+UserData.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: UserDataClient {
    public func getAvailableStudyObjectives(completion: @escaping Completion<[StudyObjective], NetworkError<EmptyAPIError>>) {
        graphQlClient.getAvailableStudyObjectives(
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let studyObjectives):
                    let availableStudyObjectives = studyObjectives.map {
                        StudyObjective(eid: $0.eid, name: $0.label, superset: $0.superset)
                    }
                    completion(.success(availableStudyObjectives))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func getCurrentUserData(cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<UserData, NetworkError<EmptyAPIError>>) {
        graphQlClient.getCurrentUserData(
            cachePolicy: cachePolicy,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let currentUser):
                    // WORAKROUND:
                    // Backend sometimes returns empty user stage, reason unclear
                    // We still do not want this call to fail, hence we default to .preclinic
                    let userData = UserData(
                        featureFlags: currentUser.features,
                        stage: UserStage(stage: currentUser.stage.value ?? .preclinic),
                        studyObjective: StudyObjective(studyObjective: currentUser.studyObjective),
                        shouldUpdateTermsAndConditions: currentUser.shouldUpdateTnC)
                    completion(.success(userData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        let mode: GraphQLEnum<Stage> = GraphQLEnum(Stage(userStage: userStage))
        graphQlClient.updateUserProfile(
            userProfileInput: UserProfileInput(mode: .some(mode)),
            completion: postprocess(authorization: self.authorization, completion: completion))
    }

    public func setStudyObjective(_ studyObjective: StudyObjective, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        graphQlClient.updateUserProfile(
            userProfileInput: UserProfileInput(studyObjectiveId: .some(studyObjective.eid)),
            completion: postprocess(authorization: self.authorization, completion: completion))
    }

    public func getUserHealthCareProfessionStatus(_ completion: @escaping Completion<Bool, NetworkError<EmptyAPIError>>) {
        graphQlClient.getCurrentUserConfiguration(
            postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let currentUserConfig):
                    let hasConfirmedHealthCareProfession = currentUserConfig.hasConfirmedHealthCareProfession
                    completion(.success(hasConfirmedHealthCareProfession))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func setHealthcareProfession(isConfirmed: Bool, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        graphQlClient.setHealthcareProfession(
            isConfirmed: isConfirmed,
            completion: postprocess(authorization: self.authorization, completion: completion))
    }

    public func getTermsAndConditions(completion: @escaping Completion<Terms?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getTermsAndConditions { result in
            switch result {
            case .success(let data):
                var terms: Terms?

                if let termsId = data.latestTermsAndConditions?.id,
                   let id = TermsIdentifier(termsId),
                   let html = data.latestTermsAndConditionsContent {
                    terms = Terms(id: id, html: html)
                }
                completion(.success(terms))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func acceptTermsAndConditions(id: TermsIdentifier, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {
        graphQlClient.updateTermsAndConditions(termsAndConditionsId: id.value) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// UserDataClient helpers
extension UserStage {
    init?(stage: Stage) {
        switch stage {
        case .clinic: self = .clinic
        case .doctor: self = .physician
        case .preclinic: self = .preclinic
        }
    }
}

extension Stage {
    init(userStage: UserStage) {
        switch userStage {
        case .clinic: self = .clinic
        case .physician: self = .doctor
        case .preclinic: self = .preclinic
        }
    }
}

extension StudyObjective {
    init?(studyObjective: CurrentUserInformationQuery.Data.CurrentUser.StudyObjective?) {
        guard let studyObjective = studyObjective else { return nil }
        self.init(eid: studyObjective.eid, name: studyObjective.label, superset: studyObjective.superset)
    }
}
