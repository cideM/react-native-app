//
//  CombinedClient+Search.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: SearchClient {

    public func getSuggestions(for text: String, resultTypes: [SearchSuggestionResultType], timeout: TimeInterval, completion: @escaping Completion<[SearchSuggestionItem], NetworkError<EmptyAPIError>>) {
        graphQlClient.getSuggestions(
            for: text,
            resultTypes: resultTypes.map { SearchResultType(type: $0) },
            timeout: timeout,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let suggestionsData):
                    let items: [SearchSuggestionItem] = suggestionsData.compactMap { item in
                        if let autocomplete = item?.asSearchSuggestionQuery {
                            return SearchSuggestionItem.autocomplete(text: autocomplete.text, value: autocomplete.value, metadata: autocomplete.metadata)
                        } else if let instantResult = item?.asSearchSuggestionInstantResult {
                            if let article = instantResult.target?.asSearchTargetArticle, let deepLink = LearningCardDeeplink(articleId: article.articleEid, particleId: article.particleEid, anchorId: article.anchorId) {
                                return .instantResult(.article(text: instantResult.text, value: instantResult.value, deepLink: deepLink, metadata: instantResult.metadata))

                            } else if
                                let pharma = instantResult.target?.asSearchTargetPharmaAgent,
                                let substanceIdentifier = SubstanceIdentifier(pharma.pharmaAgentId),
                                let drugIdentifier = DrugIdentifier(pharma.drugId) {
                                let deepLink = PharmaCardDeeplink(substance: substanceIdentifier, drug: drugIdentifier, document: nil)
                                return .instantResult(.pharmaCard(text: instantResult.text, value: instantResult.value, deepLink: deepLink, metadata: instantResult.metadata))

                            } else if let monograph = instantResult.target?.asSearchTargetPharmaMonograph {
                                guard let monographIdentifier = MonographIdentifier(monograph.pharmaMonographId) else { return nil }
                                return .instantResult(.monograph(text: instantResult.text, value: instantResult.value, deepLink: MonographDeeplink(monograph: monographIdentifier, anchor: nil), metadata: instantResult.metadata))
                            }
                        }
                        return nil
                    }
                    completion(.success(items))

                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func overviewSearchDE(for text: String, limit: Int, timeout: TimeInterval, completion: @escaping Completion<SearchOverviewResult, NetworkError<EmptyAPIError>>) {
        self.overViewSearch(for: text,
                            limit: limit,
                            timeout: timeout,
                            supportsMonograph: false,
                            isMonographSearchAvailable: false,
                            completion: completion)
    }

    public func overviewSearchUS(for text: String, limit: Int, timeout: TimeInterval, isMonographSearchAvailable: Bool, completion: @escaping Completion<SearchOverviewResult, NetworkError<EmptyAPIError>>) {
        self.overViewSearch(for: text,
                            limit: limit,
                            timeout: timeout,
                            supportsMonograph: true,
                            isMonographSearchAvailable: isMonographSearchAvailable,
                            completion: completion)
    }

    public func getArticleResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<ArticleSearchItem>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getArticleResults(
            for: text,
            limit: limit,
            timeout: timeout,
            after: after,
            completion: postprocess(authorization: authorization) { result in
                switch result {
                case .success(let searchArticleContentTree):
                    do {
                        let page = try Page(articleContentTree: searchArticleContentTree)
                        completion(.success(page))
                    } catch {
                        completion(.failure(.invalidFormat(error.localizedDescription)))
                    }

                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func getPharmaResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<PharmaSearchItem>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getPharmaResults(
            for: text,
            limit: limit,
            timeout: timeout,
            after: after,
            completion: postprocess(authorization: authorization) { result in
                switch result {
                case .success(let pharmaResultData):
                    do {
                        let page = try Page(searchPharmaResult: pharmaResultData)
                        completion(.success(page))
                    } catch {
                        completion(.failure(.invalidFormat(error.localizedDescription)))
                    }

                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func getMonographResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<MonographSearchItem>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getMonographResults(
            for: text,
            limit: limit,
            timeout: timeout,
            after: after,
            completion: postprocess(authorization: authorization) { result in
                switch result {
                case .success(let monographResultData):
                    do {
                        let page = try Page(searchMonographResult: monographResultData)
                        completion(.success(page))
                    } catch {
                        completion(.failure(.invalidFormat(error.localizedDescription)))
                    }

                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func getGuidelineResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<GuidelineSearchItem>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getGuidelineResults(
            for: text,
            limit: limit,
            timeout: timeout,
            after: after,
            completion: postprocess(authorization: authorization) { result in
                switch result {
                case .success(let guidelineResultData):
                    do {
                        let page = try Page(searchGuidelineResult: guidelineResultData)
                        completion(.success(page))
                    } catch {
                        completion(.failure(.invalidFormat(error.localizedDescription)))
                    }
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    public func getMediaResults(for text: String, mediaFilters: [String], limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<(Page<MediaSearchItem>?, MediaFiltersResult), NetworkError<EmptyAPIError>>) {
        graphQlClient.getMediaResults(
            for: text,
            mediaFilters: mediaFilters,
            limit: limit,
            timeout: timeout,
            after: after,
            completion: postprocess(authorization: authorization) { result in
                switch result {
                case .success(let mediaResultData):
                    do {

                        let page = try Page(searchMediaResult: mediaResultData)
                        let filters = mediaResultData.filters.mediaType.map { MediaFilter(value: $0.value, label: $0.label, matchingCount: $0.matchingCount ?? 0, isActive: $0.isActive) }
                        completion(.success((page, MediaFiltersResult(filters: filters))))
                    } catch {
                        completion(.failure(.invalidFormat(error.localizedDescription)))
                    }
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

}

// SearchClient helpers
fileprivate extension CombinedClient {

    private func overViewSearch(for text: String, limit: Int, timeout: TimeInterval, supportsMonograph: Bool, isMonographSearchAvailable: Bool, completion: @escaping Completion<SearchOverviewResult, NetworkError<EmptyAPIError>>) {
        graphQlClient.overviewSearch(
            for: text,
            limit: limit,
            timeout: timeout,
            completion: postprocess(authorization: authorization) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let data):
                    let searchOverviewResult = self.parseOverviewSearchResultData(data, supportsMonograph: supportsMonograph, isMonographSearchAvailable: isMonographSearchAvailable)
                    completion(.success(searchOverviewResult))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }

    private func parseOverviewPhrasionary(_ data: SearchOverviewResultsQuery.Data) -> PhrasionaryItem? {
        guard let phrasionaryData = data.searchPhrasionary else { return nil }
        var targets = [SearchResultItem]()
        if let targetsData = data.searchPhrasionary?.secondaryTargets {
            for target in targetsData {
                if
                    let _target = target.target.asSearchTargetArticle,
                    let deeplink = LearningCardDeeplink(articleId: _target.articleEid, particleId: _target.particleEid, anchorId: _target.anchorId) {
                    targets.append(
                        .article(ArticleSearchItem(title: target.title, body: nil, deepLink: deeplink, children: [], resultUUID: "", targetUUID: _target._trackingUuid))
                    )
                }
            }
        }
        return PhrasionaryItem(title: phrasionaryData.title,
                               body: phrasionaryData.body,
                               synonyms: phrasionaryData.synonyms,
                               etymology: phrasionaryData.etymology,
                               targets: targets,
                               resultUUID: phrasionaryData._trackingUuid)
    }

    private func parseOverviewPharmaInfoForMonographs(_ data: SearchOverviewResultsQuery.Data) -> SearchOverviewResult.PharmaInfo? {
        let result = data.searchAmbossSubstanceResults
        let searchMonographResults = result.edges.compactMap { MonographSearchItem(from: $0?.node) }
        return .monograph(monographItems: searchMonographResults,
                          monographItemsTotalCount: result.totalCount,
                          pageInfo: SearchOverviewResult.PageInfo(
                            endCursor: result.pageInfo.endCursor,
                            hasNextPage: result.pageInfo.hasNextPage))
    }

    private func parseOverviewPharmaInfoForPharmaCards(_ data: SearchOverviewResultsQuery.Data) -> SearchOverviewResult.PharmaInfo? {
        let searchPharmaResults = data.searchPharmaAgentResults.edges.compactMap { PharmaSearchItem(from: $0?.node) }
        return .pharmaCard(pharmaItems: searchPharmaResults, pharmaItemsTotalCount: data.searchPharmaAgentResults.totalCount, pageInfo: SearchOverviewResult.PageInfo(endCursor: data.searchPharmaAgentResults.pageInfo.endCursor, hasNextPage: data.searchPharmaAgentResults.pageInfo.hasNextPage))
    }

    private func parseOverviewSearchResultData(_ data: SearchOverviewResultsQuery.Data, supportsMonograph: Bool, isMonographSearchAvailable: Bool) -> SearchOverviewResult {

        let phrasionary: PhrasionaryItem? = self.parseOverviewPhrasionary(data)

        let searchArticleResults = data.searchArticleContentTree.edges.compactMap { ArticleSearchItem(from: $0?.node) }
        var pharmaInfo: SearchOverviewResult.PharmaInfo?
        if supportsMonograph {
            if isMonographSearchAvailable {
                pharmaInfo = parseOverviewPharmaInfoForMonographs(data)
            }
        } else {
            pharmaInfo = parseOverviewPharmaInfoForPharmaCards(data)
        }

        let searchGuidelineResults = data.searchGuidelineResults.edges.compactMap { GuidelineSearchItem(from: $0?.node) }
        let mediaResults: [MediaSearchItem] = data.searchMediaResults.edges.compactMap { MediaSearchItem(from: $0?.node) }
        let mediaFilters = data.searchMediaResults.filters.mediaType.map { MediaFilter(value: $0.value, label: $0.label, matchingCount: $0.matchingCount ?? 0, isActive: $0.isActive) }
        let mediaItemsTotalCount = data.searchMediaResults.totalCount
        let searchResultOverviewSectionOrder = data.searchInfo.overviewSectionOrder
            .compactMap {
                if let value = $0.value {
                    return SearchResultContentType(type: value)
                } else {
                    return nil
                }
            }

        var targetScope: SearchResultsTargetScope?
        if let targetView = data.searchInfo.resultInfo.targetView?.value {
            targetScope = SearchResultsTargetScope(view: targetView)
        }

        var correctedSearchTerm: String?
        // "isEmpty" is just to make extrra sure, it does not really happen ...
        if data.searchInfo.queryInfo.wasAutocorrected, !data.searchInfo.queryInfo.processedQuery.isEmpty {
            // "processedQuery" will always contain a search term,
            // if its not autocorrected it will just be what the user entered ...
            correctedSearchTerm = data.searchInfo.queryInfo.processedQuery
        }

        let searchOverviewResult = SearchOverviewResult(
            phrasionary: phrasionary,
            articleItems: searchArticleResults,
            articleItemsTotalCount: data.searchArticleContentTree.totalCount,
            articlePageInfo: .init(endCursor: data.searchArticleContentTree.pageInfo.endCursor,
                                   hasNextPage: data.searchArticleContentTree.pageInfo.hasNextPage),
            pharmaInfo: pharmaInfo,
            guidelineItems: searchGuidelineResults,
            guidelineItemsTotalCount: data.searchGuidelineResults.totalCount,
            guidelinePageInfo: .init(endCursor: data.searchGuidelineResults.pageInfo.endCursor,
                                     hasNextPage: data.searchGuidelineResults.pageInfo.hasNextPage),
            mediaItems: mediaResults,
            mediaFiltersResult: .init(filters: mediaFilters),
            mediaItemsTotalCount: mediaItemsTotalCount,
            mediaPageInfo: .init(endCursor: data.searchMediaResults.pageInfo.endCursor,
                                 hasNextPage: data.searchMediaResults.pageInfo.hasNextPage),
            correctedSearchTerm: correctedSearchTerm,
            overviewSectionOrder: searchResultOverviewSectionOrder,
            targetScope: targetScope)

        return searchOverviewResult
    }

}

extension SearchResultContentType {
    init?(type: SearchResultType) {
        switch type {
        case .phrasionary: self = .phrasionary
        case .article: self = .article
        case .pharmaAgent: self = .pharmaSubstance
        case .pharmaMonograph: self = .pharmaMonograph
        case .mediaGroup: self = .media
        case .guideline: self = .guideline
        case .libraryList: self = .libraryList
        case .course: self = .course
        }
    }
}

extension SearchResultsTargetScope {
    init?(view: SearchResultsView) {
        switch view {
        case .overview: self = .overview
        case .article: self = .article
        case .pharma: self = .pharma
        case .media: self = .media
        case .guideline: self = .guideline
        }
    }
}

extension SearchResultType {
    init(type: SearchSuggestionResultType) {
        switch type {
        case .phrasionary:
            self = .phrasionary
        case .article:
            self = .article
        case .pharmaSubstance:
            self = .pharmaAgent
        case .pharmaMonograph:
            self = .pharmaMonograph
        case .mediaGroup:
            self = .mediaGroup
        case .guideline:
            self = .guideline
        case .libraryList:
            self = .libraryList
        case .course:
            self = .course
        }
    }
}
extension MediaSearchItem {
    init?(from node: SearchOverviewResultsQuery.Data.SearchMediaResults.Edge.Node?) {
        guard
            let node = node,
            let url = URL(string: node.target.assetUrl)
        else { return nil }

        let target = node.target
        let mediaId = target.mediaEid
        let title = node.title
        let externalAddition: MediaSearchItem.ExternalAddition?

        if
            let graphQLExternalAdditionType = target.externalAdditionType,
            let externalAdditionUrlString = target.externalAdditionUrl,
            let externalAdditionUrl = URL(string: externalAdditionUrlString),
            let additionType = graphQLExternalAdditionType.value {
            externalAddition = MediaSearchItem.ExternalAddition(type: MediaSearchItem.externalAdditionType(from: additionType), url: externalAdditionUrl)
        } else {
            externalAddition = nil
        }
        let category = MediaSearchItem.mediaCategotyType(from: node.mediaType.category.value ?? .photo)
        self.init( mediaId: mediaId, title: title, url: url, externalAddition: externalAddition, category: category, typeName: node.mediaType.label, resultUUID: node._trackingUuid, targetUUID: target._trackingUuid)
    }

    init?(from node: SearchMediaResultsQuery.Data.SearchMediaResults.Edge.Node?) {
        guard
            let node = node,
            let url = URL(string: node.target.assetUrl),
            node.target.externalAdditionType != SearchTargetMediaAdditionType.auditor
        else { return nil }

        let target = node.target

        let mediaId = target.mediaEid
        let title = node.title
        let externalAddition: MediaSearchItem.ExternalAddition?

        if let graphQLExternalAdditionType = target.externalAdditionType?.value, let externalAdditionUrlString = target.externalAdditionUrl, let externalAdditionUrl = URL(string: externalAdditionUrlString) {
            externalAddition = MediaSearchItem.ExternalAddition(type: MediaSearchItem.externalAdditionType(from: graphQLExternalAdditionType), url: externalAdditionUrl)
        } else {
            externalAddition = nil
        }
        let category = MediaSearchItem.mediaCategotyType(from: node.mediaType.category.value ?? .photo)
        self.init(mediaId: mediaId, title: title, url: url, externalAddition: externalAddition, category: category, typeName: node.mediaType.label, resultUUID: node._trackingUuid, targetUUID: target._trackingUuid)

    }

    static func externalAdditionType(from type: SearchTargetMediaAdditionType) -> Domain.ExternalAddition.Types {
        let externalAdditionType: Domain.ExternalAddition.Types
        switch type {
        case .meditricks: externalAdditionType = Domain.ExternalAddition.Types.meditricks
        case .meditricksNeuroanatomy: externalAdditionType = Domain.ExternalAddition.Types.meditricksNeuroanatomy
        case .webContent: externalAdditionType = Domain.ExternalAddition.Types.miamedWebContent
        case .easyradiology: externalAdditionType = Domain.ExternalAddition.Types.easyradiology
        case .smartzoom: externalAdditionType = Domain.ExternalAddition.Types.smartzoom
        case .video: externalAdditionType = Domain.ExternalAddition.Types.video
        case .calculator: externalAdditionType = Domain.ExternalAddition.Types.miamedCalculator
        case .auditor: externalAdditionType = Domain.ExternalAddition.Types.miamedAuditor
        case .patientInformation: externalAdditionType = Domain.ExternalAddition.Types.miamedPatientInformation
        case .threeDModel: externalAdditionType = Domain.ExternalAddition.Types.miamed3dModel
        }
        return externalAdditionType
    }

    static func mediaCategotyType(from type: SearchMediaTypeCategory) -> MediaSearchItem.Category {
        let externalAdditionType: MediaSearchItem.Category
        switch type {
        case .flowchart: externalAdditionType = MediaSearchItem.Category.flowchart
        case .illustration: externalAdditionType = MediaSearchItem.Category.illustration
        case .photo: externalAdditionType = MediaSearchItem.Category.photo
        case .imaging: externalAdditionType = MediaSearchItem.Category.imaging
        case .chart: externalAdditionType = MediaSearchItem.Category.chart
        case .microscopy: externalAdditionType = MediaSearchItem.Category.microscopy
        case .audio: externalAdditionType = MediaSearchItem.Category.audio
        case .auditor: externalAdditionType = MediaSearchItem.Category.auditor
        case .video: externalAdditionType = MediaSearchItem.Category.video
        case .calculator: externalAdditionType = MediaSearchItem.Category.calculator
        case .webContent: externalAdditionType = MediaSearchItem.Category.webContent
        case .meditricks: externalAdditionType = MediaSearchItem.Category.meditricks
        case .smartzoom: externalAdditionType = MediaSearchItem.Category.smartzoom
        case .effigos: externalAdditionType = MediaSearchItem.Category.effigos
        }
        return externalAdditionType
    }
}

extension GuidelineSearchItem {

    init?(from node: SearchOverviewResultsQuery.Data.SearchGuidelineResults.Edge.Node?) {
        guard let node = node,
              let target = node.target else { return nil }
        let tags = node.labels?.compactMap { $0 }
        let title = node.title
        let details = node.details?.compactMap { $0 }
        let externalURL = node.target?.externalUrl
        self.init(tags: tags, title: title, details: details, externalURL: externalURL, resultUUID: node._trackingUuid, targetUUID: target._trackingUuid)
    }

    init?(from node: SearchGuidelineResultsQuery.Data.SearchGuidelineResults.Edge.Node?) {
        guard let node = node,
              let target = node.target else { return nil }
        let tags = node.labels?.compactMap { $0 }
        let title = node.title
        let details = node.details?.compactMap { $0 }
        let externalURL = node.target?.externalUrl
        self.init(tags: tags, title: title, details: details, externalURL: externalURL, resultUUID: node._trackingUuid, targetUUID: target._trackingUuid)
    }
}

extension ArticleSearchItem {

    init?(from node: SearchArticleContentTreeNodeType?) {
        guard let node = node else { return nil }

        let target = node.fields.target
        let articleId = target.articleEid
        guard let learningCardDeepLink = LearningCardDeeplink(articleId: articleId, particleId: target.sectionEid, anchorId: target.nodeId) else { return nil }

        let children: [ArticleSearchItem] = node.childNodes.compactMap { ArticleSearchItem(from: $0) }
        // No subtitle available in new search API ->
        // the field should be removed from the model after the migration
        self.init(title: node.fields.title,
                  body: node.fields.snippet,
                  deepLink: learningCardDeepLink,
                  children: children,
                  resultUUID: node.fields._trackingUuid,
                  targetUUID: node.fields.target._trackingUuid)
    }
}

extension PharmaSearchItem {

    init?(from node: SearchOverviewResultsQuery.Data.SearchPharmaAgentResults.Edge.Node?) {
        guard let node = node else { return nil }
        let details = node.details?.compactMap { $0 }

        let substanceID = SubstanceIdentifier(value: node.target.pharmaAgentId)
        let drugIdentifier = DrugIdentifier(value: node.target.drugId)

        self.init(title: node.title, details: details, substanceID: substanceID, drugid: drugIdentifier, resultUUID: node._trackingUuid, targetUUID: node.target._trackingUuid)
    }

    init?(from node: SearchPharmaResultsQuery.Data.SearchPharmaAgentResults.Edge.Node?) {
        guard let node = node else { return nil }
        let details = node.details?.compactMap { $0 }

        let substanceID = SubstanceIdentifier(value: node.target.pharmaAgentId)
        let drugIdentifier = DrugIdentifier(value: node.target.drugId)

        self.init(title: node.title,
                  details: details,
                  substanceID: substanceID,
                  drugid: drugIdentifier,
                  resultUUID: node._trackingUuid,
                  targetUUID: node.target._trackingUuid)
    }
}

extension MonographSearchItem {

    init?(from node: SearchMonographContentTreeNodeType?) {
        guard let node = node else { return nil }

        let target = node.fields.target
        let monographId = MonographIdentifier(value: target.ambossSubstanceId)
        var anchorId: MonographAnchorIdentifier?

        if let anchor = target.anchorId {
            anchorId = MonographAnchorIdentifier(anchor)
        }

        let children: [MonographSearchItem] = node.childNodes.compactMap { MonographSearchItem(from: $0) }
        self.init(id: monographId,
                  anchor: anchorId,
                  title: node.fields.title,
                  details: node.fields.details?.compactMap { $0 },
                  children: children,
                  resultUUID: node.fields._trackingUuid,
                  targetUUID: node.fields.target._trackingUuid
        )
    }
}

extension LearningCardDeeplink {
    init?(articleId: String, particleId: String?, anchorId: String?) {
        let learningCard = LearningCardIdentifier(value: articleId)
        let anchor = anchorId.map { LearningCardAnchorIdentifier(value: $0) }
        let particle = particleId.map { LearningCardAnchorIdentifier(value: $0) }
        self.init(learningCard: learningCard, anchor: anchor, particle: particle, sourceAnchor: nil)
    }
}
