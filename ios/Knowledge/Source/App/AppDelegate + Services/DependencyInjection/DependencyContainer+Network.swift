//
//  DependencyContainer+Network.swift
//  Knowledge
//
//  Created by CSH on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Domain
import Networking

extension DependencyContainer {

    fileprivate static var client: CombinedClient = {
        let configuration: URLConfiguration = AppConfiguration.shared
        let authorizationRepository: AuthorizationRepositoryType = shared.resolve()
        let client = CombinedClient(graphQlURL: configuration.graphQLURL,
                                    restURL: configuration.restBaseURL,
                                    authorization: authorizationRepository.authorization,
                                    applicationIdentifier: "AMBOSS-Knowledge")
        return client
    }()
    static var network = module {
        single { AuthorizationRepository(storage: shared.resolve(tag: DIKitTag.Storage.secure)) as AuthorizationRepositoryType }
        single { client as PharmaClient }
        single { client as AuthenticationClient }
        single { client as UserDataClient }
        single { client as MediaClient }
        single { client as LearningCardLibraryClient }
        single { client as SearchClient }
        single { client as KnowledgeClient }
        single { client as QbankClient }
        single { client as MembershipAccessClient }
        single { client as SnippetClient }
        single { FirebaseRemoteConfig() as RemoteConfigType }
        single { MediaRepository() as MediaRepositoryType }
    }
}
