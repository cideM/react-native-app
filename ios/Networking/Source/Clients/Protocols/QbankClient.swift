//
//  QbankClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol QbankClient: AnyObject {

    /// This methods returns the list of the most recent answers of the current user
    /// - Parameters:
    ///   - after: The pagination cursor from which the pagination should start.
    ///   - completion: A completion handler that will be called with result.
    func getMostRecentAnswerStatuses(after: PaginationCursor?, completion: @escaping Completion<Page<QBankAnswer>?, NetworkError<EmptyAPIError>>)
}
