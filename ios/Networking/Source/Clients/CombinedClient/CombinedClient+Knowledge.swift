//
//  CombinedClient+swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: KnowledgeClient {

    public func getDeprecationList(_ completion: @escaping Completion<[DeprecationItem], NetworkError<EmptyAPIError>>) {
        graphQlClient.getDeprecationList(
            postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let list):
                    completion(.success(list.compactMap { DeprecationItem(from: $0) }))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }
}

// KnowledgeClient helpers
extension DeprecationItem {
    init?(from item: MobileDeprecationListQuery.Data.MobileDeprecationList?) {
        guard let item = item else { return nil }

        var deprecationExplanationUrl: URL?
        if let deprecationExplanationUrlString = item.deprecationExplanationUrl {
            deprecationExplanationUrl = URL(string: deprecationExplanationUrlString)
        }

        let platform: DeprecationItem.Platform = DeprecationItem.Platform(rawValue: item.mobilePlatform.rawValue) ?? .unknown
        let deprecationType: DeprecationItem.DeprecationType = item.deprecationType == .unsupported ? .unsupported : .unknown

        self.init(minVersion: item.minVersion, maxVersion: item.maxVersion, type: deprecationType, platform: platform, identifier: item.mobileIdentifier, url: deprecationExplanationUrl)
    }
}
