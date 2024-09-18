//
//  AmbossInterceptorProviderStore.swift
//  Networking
//
//  Created by Elmar Tampe on 21.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public class AmbossInterceptorProviderStore {

    public static let sharedInstance: AmbossInterceptorProviderStore = {
        AmbossInterceptorProviderStore()
    }()

    var authToken: String?
    var requestTimeOut: TimeInterval?
}
