//
//  DependencyContainer+Repository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

extension DependencyContainer {
    static var repository = module {
        single { TagRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as TagRepositoryType }
        single { ExtensionRepository(storage: shared.resolve(tag: DIKitTag.Storage.large)) as ExtensionRepositoryType }
        single { LearningCardOptionsRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as LearningCardOptionsRepositoryType }
        single { UserDataRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as UserDataRepositoryType }
        single { DeviceSettingsRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as DeviceSettingsRepositoryType }
        single { SharedExtensionRepository(userDefaultsStorage: shared.resolve(tag: DIKitTag.Storage.default), fileStorage: shared.resolve(tag: DIKitTag.Storage.large)) as SharedExtensionRepositoryType }
        single { FeedbackRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as FeedbackRepositoryType }
        single { AccessRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as AccessRepositoryType }
        single { QBankAnswerRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as QBankAnswerRepositoryType }
        single { SearchHistoryRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as SearchHistoryRepositoryType }
        single { SnippetRepository() as SnippetRepositoryType }
        single { SearchSuggestionRepository() as SearchSuggestionRepositoryType }
        single { SearchRepository() as SearchRepositoryType }
        single { appReviewRepository as AppReviewRepositoryType }
        single { UserStageRepository() as UserStageRepositoryType }
        single { KillSwitchRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as KillSwitchRepositoryType }
        single { ReadingRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as ReadingRepositoryType }
        single { FeatureFlagRepository(storage: shared.resolve(tag: DIKitTag.Storage.default)) as FeatureFlagRepositoryType }
        single { RemoteConfigRepository() as RemoteConfigRepositoryType }
        single { PharmaRepository() as PharmaRepositoryType }
        single { RegistrationRepository() as RegistrationRepositoryType }
        single { MonographRepository() as MonographRepositoryType }
        single { ShortcutsRepository() as ShortcutsRepositoryType }
        single { ExternalMediaRepository() as ExternalMediaRepositoryType }
    }
}
