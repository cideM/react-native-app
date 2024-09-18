//
//  CombinedClient+Media.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: MediaClient {

    public func getExternalAddition(_ externalAdditionId: ExternalAdditionIdentifier, completion: @escaping Completion<ExternalAddition, NetworkError<AccessProtectedError>>) {
        graphQlClient.getMediaAsset(
            externalAdditionId.value,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let mediaAsset):
                    if let mediaAsset = mediaAsset,
                       let externalAddition = ExternalAddition(from: mediaAsset) {
                        completion(.success(externalAddition))
                    } else {
                        completion(.failure(.apiResponseError([.accessBlocked])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func downloadData(at url: URL, completion: @escaping Completion<Data, NetworkError<EmptyAPIError>>) {
        restClient.downloadData(
            at: url,
            completion: postprocess(authorization: self.authorization, completion: completion))
    }
}

extension Domain.ExternalAddition {
    init?(from mediaAsset: MediaAssetsQuery.Data.MediaAsset) {
        guard let externalAddition = mediaAsset.externalAddition?.asExternalAddition, let value = externalAddition.type.value else { return nil }

        self.init(identifier: ExternalAdditionIdentifier(value: mediaAsset.eid),
                  type: Types(from: value),
                  isFree: externalAddition.isFreebie,
                  url: URL(string: externalAddition.url))

    }
}

extension Domain.ExternalAddition.Types {

    init(from additionType: AdditionType) {
        switch additionType {
        case .meditricks: self = .meditricks
        case .meditricksNeuroanatomy: self = .meditricksNeuroanatomy
        case .smartzoom: self = .smartzoom
        case .calculator: self = .miamedCalculator
        case .webContent: self = .miamedWebContent
        case .auditor: self = .miamedAuditor
        case .threeDModel: self = .miamed3dModel
        case .patientInformation: self = .miamedPatientInformation
        case .easyradiology: self = .easyradiology
        case .video: self = .video
        }
    }
}
