//
//  CombinedClient+AccessClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: MembershipAccessClient {

    public func getAmbossSubscriptionState(_ completion: @escaping Completion<AmbossSubscriptionState, NetworkError<EmptyAPIError>>) {
        graphQlClient.getAmbossSubscriptionState(
            postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let data):
                    let item = AmbossSubscriptionState(canPurchaseInAppSubscription: data.currentUserCanBuyIosSubscription, hasActiveInAppSubscription: (data.currentUserActiveIosSubscription != nil))
                    completion(.success(item))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func getHasTrialAccess(_ completion: @escaping Completion<Bool, NetworkError<EmptyAPIError>>) {
        graphQlClient.getHasTrialAccess(
            postprocess(authorization: self.authorization,
                        completion: completion))
    }

    public func uploadInAppPurchaseSubscriptionReceipt(receiptData: Data, countryCode: String, completion: @escaping Completion<Void, NetworkError<InAppPurchaseError>>) {
        graphQlClient.uploadInAppPurchaseSubscriptionReceipt(
            receiptData: receiptData,
            countryCode: countryCode,
            completion: postprocess(authorization: self.authorization,
                                    completion: completion))
    }

    public func applyAccessCode(code: String, completion: @escaping Completion<Void, NetworkError<ProductKeyError>>) {
        graphQlClient.applyProductKey(code: code, completion: postprocess(authorization: self.authorization, completion: { result in
            switch result {
            case .success(let data):
                if data.applyProductKey.asApplyProductKeyResult != nil {
                    completion(.success(()))
                } else if let result = data.applyProductKey.asProductKeyError {
                    completion(.failure(NetworkError.apiResponseError([ProductKeyError(message: result.message,
                                                                                       errorCode: result.errorCode.value ?? .unexpectedErrorWhenApplyingKey)])))
                }
            case .failure(let error):
                let returnError: NetworkError<ProductKeyError>
                switch error {

                case .noInternetConnection:
                    returnError = .noInternetConnection
                case .requestTimedOut:
                    returnError = .requestTimedOut
                case .failed(let code):
                    returnError = .failed(code: code)
                case .authTokenIsInvalid(let descirption):
                    returnError = .authTokenIsInvalid(descirption)
                case .invalidFormat(let description):
                    returnError = .invalidFormat(description)
                case .apiResponseError:
                    returnError = .apiResponseError([])
                case .other(let description, let code):
                    returnError = .other(description, code: code)
                }
                completion(.failure(returnError))
            }
        }))
    }
}

extension ProductKeyError {
    init(message: String, errorCode: ProductKeyErrorCode) {
        self.message = message
        switch errorCode {
        case .invalidKey,
                .expiredKey,
                .marburgerKey,
                .keyNotFound,
                .maxUserReached,
                .alreadyRegistered,
                .alreadyGroupMember:
            self.errorType = .keyNotValid
        case .activeSubscription,
                .balanceActiveSubscription,
                .activeSubscriptionLongAccess:
            self.errorType = .alreadySubscribed
        case .unexpectedErrorWhenApplyingKey:
            self.errorType = .unknown
        }
    }
}
