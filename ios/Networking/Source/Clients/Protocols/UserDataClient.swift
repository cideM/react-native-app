//
//  UserDataClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol UserDataClient: AnyObject {

    /// Gets the current user's user data
    /// - Parameter completion: A completion handler will be called with the result of UserData
    func getCurrentUserData(cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<UserData, NetworkError<EmptyAPIError>>)

    /// This method uploads the user stage
    /// - Parameters:
    ///   - userStage: The user selected user stage.
    ///   - completion: A completion handler that will be called with result.
    func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)

    /// This method uploads the user study objective.
    /// - Parameters:
    ///   - studyObjective: The user selected study objective.
    ///   - completion: A completion handler that will be called with result.
    func setStudyObjective(_ studyObjective: StudyObjective, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)

    /// This method updates the users agreement status of being a healthcare professional.
    /// - Parameters:
    ///   - isConfirmed: A boolean indicated if the user has agreed to be a healthcare professional.
    ///   - completion: A completion handler that will be called with result.
    func setHealthcareProfession(isConfirmed: Bool, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)

    /// This method returns current user configuration.
    /// - Parameter completion: A completion handler that will be called with result. On success should return a boolean telling whether the user has confirmed health care profession or not.
    func getUserHealthCareProfessionStatus(_ completion: @escaping Completion<Bool, NetworkError<EmptyAPIError>>)

    /// Requests all `AvailableStudyObjective`s
    ///
    ///  This method is unique for every user thats why requries a logged in user to work. We are using this method in the settings study objectives section.
    ///
    /// - Parameters:
    ///   - completion: A completion handler that will be called with the result of the availablestudyobjective fetch request.
    func getAvailableStudyObjectives(completion: @escaping Completion<[StudyObjective], NetworkError<EmptyAPIError>>)

    /// Requests updated terms (as html string) if any
    ///
    ///  This method returns an options `Terms` object cause there might exist a state on the backend
    ///  where the terms `id` has already been created in the db but not filled with content
    ///  If that's the case no action needs to be taken. The object will be available eventually.
    ///  The terms content is updated by the mobile team after the onboarding team has created the db item
    ///  hence there might be a bit of time passing between one and the other ...
    ///
    /// - Parameters:
    ///   - completion: A completion handler that will be called with the result of the availablestudyobjective fetch request.
    func getTermsAndConditions(completion: @escaping Completion<Terms?, NetworkError<EmptyAPIError>>)

    /// Sends the ID of the terms which the user has agreed to
    ///
    /// One the ID has been sent the `shouldUpdateTnC` field inside the user object
    /// will update to `false` in case no further terms need acceptance
    /// - Parameters:
    ///   - completion: A completion handler that will either return empty and succesfull or with an error
    func acceptTermsAndConditions(id: TermsIdentifier, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>)
}
