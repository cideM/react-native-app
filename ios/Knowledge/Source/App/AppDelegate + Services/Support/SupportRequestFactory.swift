//
//  SupportRequestFactory.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 10.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import Networking

final class SupportRequestFactory {

    private var deviceId: String?
    private let appConfiguration: Configuration
    private let searchHistoryRepository: SearchHistoryRepositoryType
    private let libraryRepository: LibraryRepositoryType

    var libraryVersionDateString: String {
        guard let libraryCreationDate = libraryRepository.library.metadata.createdAt else { return "" }
        return DateFormatter.rfc1123.string(from: libraryCreationDate)
    }

    init(appConfiguration: Configuration = AppConfiguration.shared, authorizationRepository: AuthorizationRepositoryType = resolve(), searchHistoryRepository: SearchHistoryRepositoryType = resolve(), libraryRepository: LibraryRepositoryType = resolve()) {
        self.appConfiguration = appConfiguration
        self.deviceId = authorizationRepository.deviceId
        self.searchHistoryRepository = searchHistoryRepository
        self.libraryRepository = libraryRepository
    }

    func pharmaSupportRequest(substanceId: SubstanceIdentifier, drugId: DrugIdentifier?) -> SupportRequestConfiguration {
        .pharma(configuration: AppConfiguration.shared, application: Application.main, device: Device.current, deviceId: self.deviceId ?? "", libraryVersionDate: libraryVersionDateString, agentId: substanceId.value, drugId: drugId?.value ?? "", lastPharmaSearchQuery: searchHistoryRepository.lastAddedHistoryItem ?? "")
    }

    func monographSupportRequest(monographId: MonographIdentifier) -> SupportRequestConfiguration {
        .monograph(configuration: AppConfiguration.shared, application: Application.main, device: Device.current, deviceId: self.deviceId ?? "", libraryVersionDate: libraryVersionDateString, monographId: monographId.value, lastMonographSearchQuery: searchHistoryRepository.lastAddedHistoryItem ?? "")
    }

    func standardSupportRequest() -> SupportRequestConfiguration {
        .standard(configuration: AppConfiguration.shared, application: Application.main, device: Device.current, deviceId: self.deviceId ?? "", libraryVersionDate: libraryVersionDateString)
    }
}
