//
//  ApolloClient.swift
//  Networking
//
//  Created by CSH on 10.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Apollo
import Common
import Foundation
import Domain
import KnowledgeGraphQLEntities

public class GraphqlClient {

    private var authToken: String?
    private var url: URL
    private let apolloClient: ApolloClient

    required init(url: URL, authToken: String?) {
        self.url = url
        self.authToken = authToken
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        let client = URLSessionClient()
        let provider = AmbossInterceptorProvider(client: client, store: store)

        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)

        // Remember to give the store you already created to the client so it
        // doesn't create one on its own
        apolloClient = ApolloClient(networkTransport: requestChainTransport, store: store)
    }

    func setAuthToken(token: String?) {
        AmbossInterceptorProviderStore.sharedInstance.authToken = token
    }

    var nextRequestTimeout: TimeInterval?
}

// final class GraphqlClient {
//
//    /// The authToken of the current user if any
//    private var authToken: String?
//
//    /// The dispatch queue all result handlers will be called on
//    private let dispatchQueue = DispatchQueue.main
//
//    /// The Apollo client that is used to perform the network requests.
//    private let apolloClient: ApolloClient
//
//    /// The `URLSessionClient` used by ApolloClient to do requests.
//    private let sessionClient: URLSessionClient
//
//    private var nextRequestTimeout: TimeInterval?
//
//    init(url: URL, authToken: String?) {
//        sessionClient = URLSessionClient(sessionConfiguration: .default)
//        let networkTransport = HTTPNetworkTransport(url: url, client: sessionClient)
//        apolloClient = ApolloClient(networkTransport: networkTransport)
//        self.authToken = authToken
//        networkTransport.delegate = self
//    }
//
//    func setAuthToken(_ token: String?) {
//        sessionClient.session.getAllTasks {
//            $0.forEach { $0.cancel() }
//        }
//        self.authToken = token
//    }
// }
//
// extension GraphqlClient: HTTPNetworkTransportPreflightDelegate {
//    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
//        true
//    }
//
//    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
//        guard let authToken = authToken else { return }
//
//        var headers = request.allHTTPHeaderFields ?? [:]
//        headers["Authorization"] = "Bearer \(authToken)"
//        request.allHTTPHeaderFields = headers
//
//        if let timeInterval = nextRequestTimeout {
//            request.timeoutInterval = timeInterval
//            nextRequestTimeout = nil
//        }
//    }
// }

extension URLRequest.CachePolicy {
    var graphQlCachePolicy: CachePolicy {
        switch self {
        case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData: return .fetchIgnoringCacheData
        case .returnCacheDataElseLoad, .useProtocolCachePolicy, .reloadRevalidatingCacheData: return .returnCacheDataElseFetch
        case .returnCacheDataDontLoad: return .returnCacheDataDontFetch
        @unknown default: return .returnCacheDataElseFetch
        }
    }
}

// Authentication
extension GraphqlClient {
    func getRegistrationStudyObjectives(completion: @escaping Completion<RegistrationStudyObjectivesQuery.Data, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: RegistrationStudyObjectivesQuery()) { (result: Result<RegistrationStudyObjectivesQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    if data.usmle != nil || data.comlex != nil {
                        completion(.success(data))
                    } else {
                        completion(.failure(.other("Server returned registration study objectives which are not in the expected format")))
                    }
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func issueOneTimeToken(timeout: TimeInterval? = nil, completion: @escaping Completion<String, NetworkError<EmptyAPIError>>) {
        if let timeout {
            nextRequestTimeout = timeout
        }

        apolloClient.perform(
            mutation: IssueOneTimeTokenMutation()) { (result: Result<IssueOneTimeTokenMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    if let token = data.issueOneTimeToken?.token {
                        completion(.success(token))
                    } else {
                        completion(.failure(NetworkError<EmptyAPIError>.other("One-Time Token is nil")))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

}
// UserData
extension GraphqlClient {
    func getAvailableStudyObjectives(completion: @escaping Completion<[AvailableStudyObjectivesQuery.Data.CurrentUser.AvailableStudyObjective], NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: AvailableStudyObjectivesQuery()) { (result: Result<AvailableStudyObjectivesQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if let studyObjectives = data.currentUser.availableStudyObjectives {
                        completion(.success(studyObjectives))
                    } else {
                        completion(.failure(.other("Server returned study objectives which are not in the expected format")))
                    }
                }
        }
    }

    func getCurrentUserData(cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<CurrentUserInformationQuery.Data.CurrentUser, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: CurrentUserInformationQuery(),
            cachePolicy: cachePolicy.graphQlCachePolicy) { (result: Result<CurrentUserInformationQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.currentUser))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func updateUserProfile(userProfileInput: UserProfileInput, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        apolloClient.perform(
            mutation: UpdateCurrentUserProfileMutation(userProfileInput: userProfileInput)) { (result: Result<UpdateCurrentUserProfileMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getCurrentUserConfiguration(_ completion: @escaping Completion<CurrentUserConfigQuery.Data.CurrentUserConfig, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(query: CurrentUserConfigQuery()) { (result: Result<CurrentUserConfigQuery.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data): completion(.success(data.currentUserConfig))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func setHealthcareProfession(isConfirmed: Bool, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        let mutation = UpdateHealthCareProfessionMutation(hasConfirmedHealthCareProfession: isConfirmed)
        apolloClient.perform(mutation: mutation) { (result: Result<UpdateHealthCareProfessionMutation.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success: completion(.success(()))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getTermsAndConditions(completion: @escaping Completion<TermsAndConditionsQuery.Data, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(query: TermsAndConditionsQuery()) { (result: Result<TermsAndConditionsQuery.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateTermsAndConditions(termsAndConditionsId: String, completion: @escaping Completion<UpdateTermsAndConditionsMutation.Data, NetworkError<EmptyAPIError>>) {
        let userProfile = UserProfileInput(termsAndConditionsId: .init(stringLiteral: termsAndConditionsId))
        let mutation = UpdateTermsAndConditionsMutation(userProfile: userProfile)
        apolloClient.perform(mutation: mutation) { (result: Result<UpdateTermsAndConditionsMutation.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
// Media
extension GraphqlClient {
    func getMediaAsset(_ externalAdditionId: String, completion: @escaping Completion<MediaAssetsQuery.Data.MediaAsset?, NetworkError<AccessProtectedError>>) {
        apolloClient.fetch(
            query: MediaAssetsQuery(featureEids: [externalAdditionId])) { (result: Result<MediaAssetsQuery.Data, NetworkError<AccessProtectedError>>) in
                switch result {
                case .success(let data): completion(.success(data.mediaAssets.first))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}
// LearningCardLibrary
extension GraphqlClient {
    func checkForLibraryUpdate(currentVersion: Int, completion: @escaping Completion<LibraryArchiveUpdateQuery.Data, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: LibraryArchiveUpdateQuery(currentVersion: currentVersion),
            resultHandler: completion)
    }

    func getLearningCardHtml(archiveVersion: Int, learningCard: LearningCardIdentifier, completion: @escaping Completion<LibraryArchiveArticleQuery.Data.LibraryArchiveArticle?, NetworkError<LearningCardHtmlAPIError>>) {
        apolloClient.fetch(
            query: LibraryArchiveArticleQuery(version: archiveVersion, eid: learningCard.value),
            cachePolicy: .returnCacheDataElseFetch) { (result: Result<LibraryArchiveArticleQuery.Data, NetworkError<LearningCardHtmlAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.libraryArchiveArticle))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func submitFeedback(_ feedback: FeedbackInput, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        apolloClient.perform(
            mutation: SubmitFeedbackMutation(input: feedback)) { (result: Result<SubmitFeedbackMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    guard data.submitFeedback.success else { return completion(.failure(.other("The GraphQL success response was false without any specific reason."))) }
                    completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getTaggings(first: Int, after: PaginationCursor?, completion: @escaping Completion<ArticleInteractionsQuery.Data.CurrentUser.ArticleInteractions?, NetworkError<EmptyAPIError>>) {
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(query: ArticleInteractionsQuery(first: first, after: optionalAfter)) { (result: Result<ArticleInteractionsQuery.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data): completion(.success(data.currentUser.articleInteractions))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func updateUserArticles(userArticlesInput: [UserArticleInput], completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {
        apolloClient.perform(
            mutation: UpdateCurrentUserArticlesMutation(userArticles: userArticlesInput)) { (result: Result<UpdateCurrentUserArticlesMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    func getUserExtensions(first: Int, after: PaginationCursor?, completion: @escaping Completion<CurrentUserExtensionsQuery.Data.CurrentUser.ParticleExtensions?, NetworkError<EmptyAPIError>>) {
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(
            query: CurrentUserExtensionsQuery(first: first, after: optionalAfter)) { (result: Result<CurrentUserExtensionsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.currentUser.particleExtensions))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func updateUserExtension(sectionId: String, text: String, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {
        apolloClient.perform(
            mutation: UpdateExtensionMutation(particleEid: sectionId, text: text)) { (result: Result<UpdateExtensionMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))

                }
        }
    }

    func getUsersWhoShareExtensionsWithCurrentUser(first: Int, after: PaginationCursor?, completion: @escaping Completion<UsersWhoShareExtensionsWithCurrentUserQuery.Data.CurrentUser.UsersWhoShareNotesWithMe?, NetworkError<EmptyAPIError>>) {
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(
            query: UsersWhoShareExtensionsWithCurrentUserQuery(first: first, after: optionalAfter)) { (result: Result<UsersWhoShareExtensionsWithCurrentUserQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.currentUser.usersWhoShareNotesWithMe))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getExtensions(for userId: String, after: PaginationCursor?, completion: @escaping Completion<ExtensionsForUserQuery.Data.UserParticleExtensions?, NetworkError<EmptyAPIError>>) {
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(query: ExtensionsForUserQuery(userId: userId, first: 50, after: optionalAfter)) { (result: Result<ExtensionsForUserQuery.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data): completion(.success(data.userParticleExtensions))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getTargetAccesses(completion: @escaping Completion<[AccessListQuery.Data.CurrentUser.MobileAccessList], NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: AccessListQuery()) { (result: Result<AccessListQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    if let accessList = data.currentUser.mobileAccessList {
                        completion(.success(accessList))
                    } else {
                        completion(.failure(NetworkError<EmptyAPIError>.other("Target Access Data is nil")))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    func uploadReadings(_ articleReadingCollection: ArticleReadingCollectionInput, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {
        apolloClient.perform(
            mutation: UploadReadingsMutation(articleReadingCollection: articleReadingCollection)) { (result: Result<UploadReadingsMutation.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}
// Search
extension GraphqlClient {
    func getSuggestions(for text: String, resultTypes: [SearchResultType], timeout: TimeInterval, completion: @escaping Completion<[SearchSuggestionsQuery.Data.SearchSuggestion?], NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout

        let mappedType: [GraphQLEnum<SearchResultType>] = resultTypes.map { obj in
                .init(obj)
        }

        let optionalSearchResultType: GraphQLNullable<[GraphQLEnum<SearchResultType>?]> = .some(mappedType)

        let query = SearchSuggestionsQuery(
            queryParam: text,
            limit: 9,
            types: optionalSearchResultType)

        apolloClient.fetch(query: query) { (result: Result<SearchSuggestionsQuery.Data, NetworkError<EmptyAPIError>>) in
            switch result {
            case .success(let data): completion(.success(data.searchSuggestions))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func overviewSearch(for text: String, limit: Int, timeout: TimeInterval, completion: @escaping Completion<SearchOverviewResultsQuery.Data, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        apolloClient.fetch(
            query: SearchOverviewResultsQuery(query: text, filters: .none, first: limit),
            resultHandler: completion)
    }

    func getArticleResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<SearchArticleResultsQuery.Data.SearchArticleContentTree, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        let optinalAfter: GraphQLNullable<String> = after ?? .none
        apolloClient.fetch(
            query: SearchArticleResultsQuery(query: text, first: limit, after: optinalAfter)) { (result: Result<SearchArticleResultsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.searchArticleContentTree))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getPharmaResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<SearchPharmaResultsQuery.Data.SearchPharmaAgentResults, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(
            query: SearchPharmaResultsQuery(query: text, first: limit, after: optionalAfter)) { (result: Result<SearchPharmaResultsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.searchPharmaAgentResults))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getMonographResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(
            query: SearchMonographResultsQuery(query: text, first: limit, after: optionalAfter)) { (result: Result<SearchMonographResultsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.searchAmbossSubstanceResults))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getGuidelineResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<SearchGuidelineResultsQuery.Data.SearchGuidelineResults, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        apolloClient.fetch(
            query: SearchGuidelineResultsQuery(query: text, first: limit, after: optionalAfter)) { (result: Result<SearchGuidelineResultsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.searchGuidelineResults))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getMediaResults(for text: String, mediaFilters: [String], limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<(SearchMediaResultsQuery.Data.SearchMediaResults), NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        let optionalAfter: GraphQLNullable<PaginationCursor> = after ?? .none
        let mappedFilters: GraphQLNullable<SearchFiltersMediaInput> = .some(.init(mediaType: .some(mediaFilters)))
        let query = SearchMediaResultsQuery(query: text,
                                            filters: mappedFilters,
                                            first: limit,
                                            after: optionalAfter)
        apolloClient.fetch(
            query: query) { (result: Result<SearchMediaResultsQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.searchMediaResults))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

}
// Knowledge
extension GraphqlClient {

    func getDeprecationList(_ completion: @escaping Completion<[MobileDeprecationListQuery.Data.MobileDeprecationList?], NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: MobileDeprecationListQuery()) { (result: Result<MobileDeprecationListQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.mobileDeprecationList ?? []))
                case .failure(let error): completion(.failure(error))
                }
        }
    }
}
// Qbank
extension GraphqlClient {
    func getMostRecentAnswerStatuses(first: Int, after cursor: PaginationCursor?, completion: @escaping Completion<MostRecentAnswerStatusesQuery.Data.CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection?, NetworkError<EmptyAPIError>>) {
        let optionalCursor: GraphQLNullable<PaginationCursor> = cursor ?? .none
        apolloClient.fetch(
            query: MostRecentAnswerStatusesQuery(first: first, after: optionalCursor)) { (result: Result<MostRecentAnswerStatusesQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.currentUser.mostRecentAnswerStatuses.asAnswerStatusConnection))
                case .failure(let error): completion(.failure(error))
                }
        }
    }
}
// Access
extension GraphqlClient {

    func getAmbossSubscriptionState(_ completion: @escaping Completion<CurrentUserIAPAccessQuery.Data, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: CurrentUserIAPAccessQuery(),
            resultHandler: completion)
    }

    func getHasTrialAccess(_ completion: @escaping Completion<Bool, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: MobileAccessesQuery()) { (result: Result<MobileAccessesQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    completion(.success(data.currentUser.trialInfo?.hasTrialAccess ?? false))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    func uploadInAppPurchaseSubscriptionReceipt(receiptData: Data, countryCode: String, completion: @escaping Completion<Void, NetworkError<InAppPurchaseError>>) {
        let files = [GraphQLFile(fieldName: "uploadFile", originalName: "receipt", data: receiptData)]

        let optionalCountryCode: GraphQLNullable<String> = .some(countryCode)

        apolloClient.upload(
            operation: UploadIosIapReceiptMutation(uploadFile: "receipt", appIdentifier: Bundle.main.bundleIdentifier ?? "unknown", countryCode: optionalCountryCode),
            files: files,
            queue: .main) { result in
                switch result {
                case .success(let data):
                    if data.data?.uploadIosIapReceipt.asIosSubscription != nil {
                        completion(.success(()))
                    } else {
                        guard let code = data.data?.uploadIosIapReceipt.asIosSubscriptionError?.code.value else {
                            completion(.failure(.apiResponseError([.permanentError])))
                            return
                        }
                        switch code {
                        case .receiptNotAuthorized, .receiptNotAuthenticated, .unexpectedError: completion(.failure(.apiResponseError([.permanentError])))
                        case .subscriptionExpired, .receiptServerNotAvailable: completion(.failure(.apiResponseError([.temporaryError])))
                        }
                    }
                case .failure:
                    completion(.failure(.apiResponseError([.temporaryError])))
                }
        }
    }

    func applyProductKey(code: String, completion: @escaping Completion<ApplyProductKeyMutation.Data, NetworkError<EmptyAPIError>>) {

        apolloClient.perform(mutation: ApplyProductKeyMutation(productKey: code), resultHandler: completion)
    }
}
// Pharma
extension GraphqlClient {
    func getPharmaCard(for substanceIdentifier: String,
                       drugIdentifier: String,
                       sorting: GraphQLEnum<PriceAndPackageSorting>,
                       timeout: TimeInterval,
                       cachePolicy: URLRequest.CachePolicy,
                       completion: @escaping Completion<PharmaCardQuery.Data, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        apolloClient.fetch(
            query: PharmaCardQuery(agentId: substanceIdentifier, drugId: drugIdentifier, sorting: sorting),
            cachePolicy: cachePolicy.graphQlCachePolicy,
            resultHandler: completion)
    }

    func getAgent(for substanceIdentifier: String, timeout: TimeInterval, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<PharmaAgentQuery.Data.AmbossSubstance, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        apolloClient.fetch(
            query: PharmaAgentQuery(id: substanceIdentifier),
            cachePolicy: cachePolicy.graphQlCachePolicy) { (result: Result<PharmaAgentQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.ambossSubstance))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getDrug(for drugIdentifier: String,
                 sorting: GraphQLEnum<PriceAndPackageSorting>,
                 timeout: TimeInterval,
                 cachePolicy: URLRequest.CachePolicy,
                 completion: @escaping Completion<PharmaDrugQuery.Data.PharmaDrug, NetworkError<EmptyAPIError>>) {
        nextRequestTimeout = timeout
        apolloClient.fetch(
            query: PharmaDrugQuery(id: drugIdentifier, sorting: sorting),
            cachePolicy: cachePolicy.graphQlCachePolicy) { (result: Result<PharmaDrugQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.pharmaDrug))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getDosage(for dosagerIdentifier: String, timeout: TimeInterval?, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<PharmaDosageQuery.Data.Dosage, NetworkError<EmptyAPIError>>) {

        nextRequestTimeout = timeout
        apolloClient.fetch(
            query: PharmaDosageQuery(id: dosagerIdentifier),
            cachePolicy: cachePolicy.graphQlCachePolicy) { (result: Result<PharmaDosageQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.dosage))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getPharmaDatabases(for majorDBVersion: Int, completion: @escaping Completion<[PharmaDatabasesQuery.Data.PharmaDatabase], NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: PharmaDatabasesQuery(pharmaDBMajorVersion: majorDBVersion)) { (result: Result<PharmaDatabasesQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data): completion(.success(data.pharmaDatabases))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    func getMonograph(for monographIdentifier: String, completion: @escaping Completion<MonographQuery.Data.AmbossSubstance.Monograph, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: MonographQuery(monographId: monographIdentifier)) { (result: Result<MonographQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    guard let monograph = data.ambossSubstance.monograph else {
                        // This is an optional but should not be missing as a value
                        // In case the backend does not find the monograph for the supplied ID the request will fail
                        // We still have to unwrap this somehow though and hence do this kind of error for a case
                        // that should actually never happen ...
                        completion(.failure(.invalidFormat("The monograph for id \(monographIdentifier) was unexpectedly missing")))
                        return
                    }
                    completion(.success(monograph))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}
// Snippet
extension GraphqlClient {
    func getPhraseGroup(for snippetIdentifier: String, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<PhraseGroupQuery.Data.PhraseGroup, NetworkError<EmptyAPIError>>) {
        apolloClient.fetch(
            query: PhraseGroupQuery(eid: snippetIdentifier),
            cachePolicy: cachePolicy.graphQlCachePolicy) { (result: Result<PhraseGroupQuery.Data, NetworkError<EmptyAPIError>>) in
                switch result {
                case .success(let data):
                    if let phraseGroup = data.phraseGroup {
                        completion(.success(phraseGroup))
                    } else {
                        completion(.failure(NetworkError<EmptyAPIError>.other("Phrase data is nil")))
                    }
                case .failure(let error): completion(.failure(error))
                }
        }
    }
}
