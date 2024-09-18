//
//  CombinedClient+LearningCardLibrary.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: LearningCardLibraryClient {

    private static let iso8601DateFormatter = ISO8601DateFormatter()

    public var downloadDelegate: DownloadDelegate? {
        get {
            restClient.downloadDelegate
        }
        set {
            restClient.downloadDelegate = newValue
        }
    }

    public func downloadFile(at url: URL, isUserInitiated: Bool, countOfBytesClientExpectsToReceive: Int64?) {
        restClient.downloadFile(
            at: url,
            isUserInitiated: isUserInitiated,
            countOfBytesClientExpectsToReceive: countOfBytesClientExpectsToReceive)
    }

    public func checkForLibraryUpdate(currentLibrary: LibraryMetadata, completion: @escaping Completion<LibraryUpdate?, NetworkError<EmptyAPIError>>) {
        graphQlClient.checkForLibraryUpdate(
            currentVersion: currentLibrary.versionId,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let data):
                    let latestArchive = data.latestFullLibraryArchive
                    if latestArchive.version == currentLibrary.versionId && currentLibrary.containsLearningCardContent {
                        completion(.success(nil))
                    } else {
                        do {
                            let libraryUpdate = try LibraryUpdate(archive: latestArchive, mode: data.fullLibraryArchive?.updateMode?.value)
                            completion(.success(libraryUpdate))
                        } catch {
                            completion(.failure(.invalidFormat(error.localizedDescription)))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func getLearningCardHtml(libraryVersion: Int, learningCard: LearningCardIdentifier, completion: @escaping Completion<String, NetworkError<LearningCardHtmlAPIError>>) {
        graphQlClient.getLearningCardHtml(
            archiveVersion: libraryVersion,
            learningCard: learningCard) { result
                in
                switch result {
                case .success(let learningCardData):
                    if let learningCardData = learningCardData {
                        let learningCardContent = learningCardData.htmlContent
                        completion(.success(learningCardContent))
                    } else {
                        completion(.failure(.apiResponseError([.learningCardNotFound])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    public func submitFeedback(_ feedback: SectionFeedback, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        graphQlClient.submitFeedback(
            FeedbackInput(with: feedback),
            completion: postprocess(authorization: self.authorization,
                                    completion: completion))
    }

    public func getTaggings(after page: PaginationCursor?, completion: @escaping Completion<Page<Tagging>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getTaggings(
            first: 50,
            after: page,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let articleInteraction):
                    if let articleInteraction = articleInteraction {
                        do {
                            let page = try Page(articleInteraction: articleInteraction, dateFormatter: Self.iso8601DateFormatter)
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

    public func uploadTaggings(_ taggings: [Tagging], completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {

        let userArticles = taggings.map { UserArticleInput(tagging: $0, dateFormatter: Self.iso8601DateFormatter) }

        graphQlClient.updateUserArticles(
            userArticlesInput: userArticles,
            completion: completion)
    }

    public func getCurrentUserExtensions(after page: PaginationCursor?, completion: @escaping Completion<Page<Extension>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getUserExtensions(
            first: 50,
            after: page,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let userExtensions):
                    if let userExtensions = userExtensions {
                        do {
                            let page = try Page(ext: userExtensions, dateFormatter: Self.iso8601DateFormatter)
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

    public func updateExtension(section: LearningCardSectionIdentifier, text: String, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {
        graphQlClient.updateUserExtension(
            sectionId: section.value,
            text: text,
            completion: postprocess(authorization: self.authorization,
                                    completion: completion))
    }

    public func getUsersWhoShareExtensionsWithCurrentUser(completion: @escaping Completion<[User], NetworkError<EmptyAPIError>>) {
        getUsersWhoShareExtensionsWithCurrentUser(
            previouslyFetchedUsers: [],
            after: nil,
            completion: completion)
    }

    private func getUsersWhoShareExtensionsWithCurrentUser(previouslyFetchedUsers: [User], after: PaginationCursor?, completion: @escaping Completion<[User], NetworkError<EmptyAPIError>>) {
        graphQlClient.getUsersWhoShareExtensionsWithCurrentUser(
            first: 50,
            after: after,
            completion: postprocess(authorization: self.authorization) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let usersData):
                    if let usersData = usersData {
                        do {
                            let page = try Page(user: usersData, dateFormatter: Self.iso8601DateFormatter)
                            let users = page?.elements ?? [] + previouslyFetchedUsers
                            if page?.hasNextPage ?? false {
                                self.getUsersWhoShareExtensionsWithCurrentUser(previouslyFetchedUsers: users, after: page?.nextPage, completion: completion)
                            } else {
                                completion(.success(users))
                            }
                        } catch {
                            completion(.failure(.invalidFormat(error.localizedDescription)))
                        }
                    } else {
                        completion(.success(previouslyFetchedUsers))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func getExtensions(for userIdentifier: UserIdentifier, after page: PaginationCursor?, completion: @escaping Completion<Page<Extension>?, NetworkError<EmptyAPIError>>) {
        graphQlClient.getExtensions(
            for: userIdentifier.value,
            after: page,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let userExtensions):
                    if let userExtensions = userExtensions {
                        do {
                            let page = try Page(ext: userExtensions, dateFormatter: Self.iso8601DateFormatter)
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

    public func getTargetAccesses(completion: @escaping Completion<[TargetAccess], NetworkError<EmptyAPIError>>) {
        graphQlClient.getTargetAccesses(
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let accessList):
                    completion(.success(accessList.compactMap { TargetAccess(item: $0, dateFormatter: Self.iso8601DateFormatter) }))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    public func uploadReadings(_ readings: [LearningCardReading], completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>) {

        /// The date format that `UploadReadingsMutation` is waiting for the `openedAt` property.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss+00:00"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)

        let referrer = ArticleReferrer.mobile
        let articleReadings = readings.map { ArticleReadingInput(reading: $0, dateFormatter: dateFormatter) }
        let articleReadingCollection = ArticleReadingCollectionInput(articleReadings: articleReadings, referrer: .case(referrer))

        graphQlClient.uploadReadings(
            articleReadingCollection,
            completion: postprocess(authorization: self.authorization,
                                    completion: completion))
    }
}

// LearningCardLibraryClient helpers
extension FeedbackInput {
    init(with sectionFeedback: SectionFeedback) {
        let message = sectionFeedback.message
        let intention = FeedbackIntentionType(rawValue: sectionFeedback.intention.rawValue)

        let sourceType: FeedbackSourceType
        switch sectionFeedback.source.type {
        case .particle: sourceType = .particle
        }
        let source = FeedbackSource(
            type: .case(sourceType),
            id: .some(sectionFeedback.source.id ?? ""),
            version: .some(sectionFeedback.source.version ?? 0))

        let appPlatform: MobilePlatform
        switch sectionFeedback.mobileInfo.appPlatform {
        case .ios: appPlatform = .ios
        }

        let appName: MobileAppName
        switch sectionFeedback.mobileInfo.appName {
        case .knowledge: appName = .knowledge
        case .wissen: appName = .wissen
        }

        let mobileInfo = FeedbackMobileInfo(
            appPlatform: .case(appPlatform),
            appName: .case(appName),
            appVersion: sectionFeedback.mobileInfo.appVersion,
            archiveVersion: sectionFeedback.mobileInfo.archiveVersion)

        self.init(message: message,
                  intention: .some(.case(intention ?? .productFeedback)),
                  source: source,
                  mobileInfo: .some(mobileInfo))
    }
}

extension ArticleReadingInput {
    init(reading: LearningCardReading, dateFormatter: DateFormatter) {
        self.init(articleEid: reading.learningCard.description,
                  createdAt: .some(dateFormatter.string(from: reading.openedAt)),
                  timeSpent: .some(reading.timeSpent))
    }
}

extension TargetAccess {
    init?(item: AccessListQuery.Data.CurrentUser.MobileAccessList, dateFormatter: ISO8601DateFormatter) {
        if let mobileAccess = item.asMobileAccess {
            guard let offlineExpiryDate = dateFormatter.date(from: mobileAccess.offlineExpiryDate) else { return nil }
            let accessTarget = AccessTarget(value: mobileAccess.target.rawValue)
            self.init(target: accessTarget, access: .granted(offlineExpiryDate))
        } else if let mobileAccessError = item.asMobileAccessError, let accessErrorCode = mobileAccessError.errorCode {
            let accessError = AccessError(string: accessErrorCode.rawValue)
            let accessTarget = AccessTarget(value: mobileAccessError.target.rawValue)
            self.init(target: accessTarget, access: .denied(accessError))
        } else {
            return nil
        }
    }
}

extension UserArticleInput {
    init(tagging: Tagging, dateFormatter: ISO8601DateFormatter) {
        var learned: GraphQLNullable<Bool> = .null
        if tagging.type == .learned {
            learned = .some(tagging.active)
        }

        var favorite: GraphQLNullable<Bool> = .null
        if tagging.type == .favorite {
            favorite = .some(tagging.active)
        }

        self.init(articleEid: tagging.learningCard.value,
                  learned: learned,
                  favorite: favorite,
                  updatedAt: .some(dateFormatter.string(from: tagging.updatedAt)))
    }
}

extension Tag {
    init?(type: ArticleInteractionType) {
        switch type {
        case .favorite: self = .favorite
        case .learned: self = .learned
        }
    }
}

extension LibraryUpdate {
    init(archive: LibraryArchiveUpdateQuery.Data.LatestFullLibraryArchive, mode: ArchiveLibraryUpdateMode?) throws {
        guard let url = URL(string: archive.url) else {
            throw NetworkError<EmptyAPIError>.invalidFormat("The url couldn't be parsed as a url")
        }
        guard let createdAt = ISO8601DateFormatter().date(from: archive.createdAt) else {
            throw NetworkError<EmptyAPIError>.invalidFormat("The date couldn't be parsed as a date")
        }

        let updateMode: LibraryUpdateMode
        switch mode {
        case .can:
            updateMode = .can
        case .should:
            updateMode = .should
        case .must:
            updateMode = .must
        default:
            updateMode = .can
        }

        self.init(
            version: archive.version,
            url: url,
            updateMode: updateMode,
            size: archive.size,
            createdAt: createdAt)
    }
}
