//
//  CombinedClient+Authentication.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

extension CombinedClient: AuthenticationClient {

    public func login(username: String, password: String, deviceId: String, completion: @escaping Completion<Authorization, NetworkError<LoginAPIError>>) {
        restClient.login(
            loginInput: LoginRequestInput(email: username, password: password),
            deviceId: deviceId) { result in
                switch result {
                case .success(let authentication):
                    let auth = Authorization(authentication: authentication)
                    self.setAuthorization(auth)
                    completion(.success(auth))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    public func signup(email: String, password: String, stage: UserStage, studyObjective: StudyObjective?, isGeneralStudyObjectiveSelected: Bool, appCode: String, skipEmailVerification: Bool, deviceId: String, completion: @escaping Completion<Void, NetworkError<SignupAPIError>>) {

        let signupInput = SignupRequestInput(email: email,
                                             password: password,
                                             stage: SignupRequestInput.Stage(stage: stage),
                                             studyObjective: studyObjective?.eid,
                                             isGeneralStudyObjectiveSelected: isGeneralStudyObjectiveSelected,
                                             appCode: appCode,
                                             skipEmailVerification: skipEmailVerification,
                                             skipAccessChooser: true)

        restClient.signup(
            signupInput: signupInput,
            deviceId: deviceId,
            completion: completion)
    }

    public func logout(deviceId: String, completion: @escaping Completion<Void, NetworkError<LogoutAPIError>>) {
        restClient.logout(deviceId: deviceId, completion: completion)
        setAuthorization(nil)
    }

    public func getRegistrationStudyObjectives(completion: @escaping Completion<[StudyObjective], NetworkError<EmptyAPIError>>) {

        graphQlClient.getRegistrationStudyObjectives(
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let data):
                    var objectives = [StudyObjective]()
                    for objective in data.usmle ?? [] {
                        objectives.append(StudyObjective(eid: objective.eid, name: objective.label))
                    }
                    for objective in data.comlex ?? [] {
                        objectives.append(StudyObjective(eid: objective.eid, name: objective.label))
                    }
                    completion(.success(objectives))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func issueOneTimeToken(timeout: TimeInterval? = nil, completion: @escaping Completion<OneTimeToken, NetworkError<EmptyAPIError>>) {
        graphQlClient.issueOneTimeToken(
            timeout: timeout,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let token): completion(.success(OneTimeToken(token: token)))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }
}

// Authentication helpers
extension Authorization {
    init(authentication: LoginResponse.Authentication) {
        self.init(token: authentication.token, user: User(user: authentication.user))
    }
}

extension User {
    init(user: LoginResponse.Authentication.User) {
        self.init(userIdentifier: UserIdentifier(value: user.userId), firstName: user.firstName, lastName: user.lastName, email: user.email)
    }
}

extension SignupRequestInput.Stage {
    init(stage: UserStage?) {
        switch stage {
        case .clinic: self = .clinic
        case .preclinic: self = .preclinic
        case .physician: self = .physician
        case .none: self = .none
        }
    }
}
