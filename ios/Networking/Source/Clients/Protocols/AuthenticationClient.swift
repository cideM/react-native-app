//
//  AuthenticationClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol AuthenticationClient: AnyObject {

    /// Performs a login request
    ///
    /// - Parameters:
    ///   - username: The username / email
    ///   - password: The user's password
    ///   - deviceId: The user's device id. The backend will provide an authorization token that is valid in conjunction with this device id.
    ///   - completion: A completion handler that will be called with the result of the login request.
    func login(username: String, password: String, deviceId: String, completion: @escaping Completion<Authorization, NetworkError<LoginAPIError>>)

    /// Performs a signup request
    /// - Parameter email: The users email address
    /// - Parameter password: The users password
    /// - Parameter stage: The selected user stage. For US server should be stage_physician or stage_clinic. For DE server this should be stage_physician, stage_clinic or stage_preclinic
    /// - Parameter appCode: This string will be part of the backlink to the app that the server provides to the user once completed the web singup flow
    /// - Parameter skipEmailVerification: This is a boolean value that indicates whether email verification step should be skipped or not. Should be always `true`.
    /// - Parameter deviceId: The user's device id. The backend will provide an authorization token that is valid in conjunction with this device id.
    /// - Parameter completion: A completion handler that will be called with the result of the signup request.
    func signup(email: String, password: String, stage: UserStage, studyObjective: StudyObjective?, isGeneralStudyObjectiveSelected: Bool, appCode: String, skipEmailVerification: Bool, deviceId: String, completion: @escaping Completion<Void, NetworkError<SignupAPIError>>)

    /// Requests all `StudyObjective`s
    ///
    /// This method is used only on the signup flow. The correct endpoint to get the available user study objectives is `getAvailableStudyObjectives`.
    /// For more information check the ticket: https://miamed.atlassian.net/browse/SPG-531
    /// - Parameters:
    ///   - completion: A completion handler that will be called with the result of the studyobjective fetch request.
    func getRegistrationStudyObjectives(completion: @escaping Completion<[StudyObjective], NetworkError<EmptyAPIError>>)

    /// Performs a Logout request
    ///
    /// - completion:  A completion handler that will be called with the result of the logout request.
    func logout(deviceId: String, completion: @escaping Completion<Void, NetworkError<LogoutAPIError>>)

    /// This method gets a One-Time Token.
    /// - Parameter completion: A completion handler that will carry the One-Time token in case of success and an error in case of failure.
    func issueOneTimeToken(timeout: TimeInterval?, completion: @escaping Completion<OneTimeToken, NetworkError<EmptyAPIError>>)
}

public extension AuthenticationClient {
    func issueOneTimeToken(timeout: TimeInterval? = nil, completion: @escaping Completion<OneTimeToken, NetworkError<EmptyAPIError>>) {
        issueOneTimeToken(timeout: timeout, completion: completion)
    }
}
