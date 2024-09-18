//
//  MembershipAccessClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol MembershipAccessClient {

    func getAmbossSubscriptionState(_ completion: @escaping Completion<AmbossSubscriptionState, NetworkError<EmptyAPIError>>)

    func getHasTrialAccess(_ completion: @escaping Completion<Bool, NetworkError<EmptyAPIError>>)

    func uploadInAppPurchaseSubscriptionReceipt(receiptData: Data, countryCode: String, completion: @escaping Completion<Void, NetworkError<InAppPurchaseError>>)

    func applyAccessCode(code: String, completion: @escaping Completion<Void, NetworkError<ProductKeyError>>)
}
