//
//  SearchError.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 15.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Networking

enum SearchError: Error {
    case networkError(NetworkError<EmptyAPIError>)
    case offlinePharmaDatabaseError(Error)
}
