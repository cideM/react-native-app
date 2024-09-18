//
//  CombinedClient+Qbank.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

extension CombinedClient: QbankClient {
    public func getMostRecentAnswerStatuses(after page: PaginationCursor?, completion: @escaping Completion<Page<QBankAnswer>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getMostRecentAnswerStatuses(
            first: 1000,
            after: page,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let answerStatusConnection):
                    if let answerStatusConnection = answerStatusConnection {
                        do {
                            let page = try Page(answerStatusConnection: answerStatusConnection)
                            completion(.success(page))
                        } catch {
                            completion(.failure(.invalidFormat(error.localizedDescription)))
                        }
                    } else {
                        completion(.success(nil))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
