//
//  LearningCardLibraryClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol LearningCardLibraryClient: AnyObject {
    var downloadDelegate: DownloadDelegate? { get set }

    /// Downloads the file referenced by a given url. Additionally the way of downloading can be defined.
    ///
    /// - Note: In order to download the file, the `downloadDelegate` needs to be defined.
    ///
    /// - Parameters:
    ///   - url: The url of the file to download.
    ///   - isUserInitiated: If set to true, the file is downloaded immediately. Otherwise the system can schedule the time at any time.
    ///   - countOfBytesClientExpectsToReceive: The rough estimated size of the file. This is used to optimize the time to schedule the download.
    func downloadFile(at url: URL, isUserInitiated: Bool, countOfBytesClientExpectsToReceive: Int64?)
    /// Checks for the lastest archive update.
    ///
    /// - Note: The returned LibraryUpdate can be an update to the same version, if the current version doesn't contain the learning card HTML.
    ///
    /// - Parameter currentLibrary: The metadata of the current library.
    /// - Parameter completion: A completion handler will be called with a LibraryUpdate if any was found.
    func checkForLibraryUpdate(currentLibrary: LibraryMetadata, completion: @escaping Completion<LibraryUpdate?, NetworkError<EmptyAPIError>>)

    /// Request content of a specific Learning Card.
    /// - Parameters:
    ///   - libraryVersion: The version of the Library.
    ///   - learningCard: Requested Learning Card identifier.
    ///   - completion: A completion handler that will be called with the the learning card html.
    func getLearningCardHtml(libraryVersion: Int, learningCard: LearningCardIdentifier, completion: @escaping Completion<String, NetworkError<LearningCardHtmlAPIError>>)

    /// This method uploads the user feedback
    /// - Parameters:
    ///   - feedback: The SectionFeedback that should be submitted to the server.
    ///   - completion: A completion handler that will be called with result.
    func submitFeedback(_ feedback: SectionFeedback, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)

    /// This method gets the user article interactions (tags)
    /// - Parameters:
    ///   - after: The pagination cursor from which the pagination should start.
    ///   - completion: A completion handler that will be called with result.
    func getTaggings(after: PaginationCursor?, completion: @escaping Completion<Page<Tagging>?, NetworkError<EmptyAPIError>>)

    /// This method upload the user article interactions (tags)
    ///
    /// Taggings should be uploaded in chuncks of 50 items per request. The caller of this method should divide the taggings into chunks of 50 items and upload them chunk by chunk.
    /// - Parameters:
    ///   - taggings: user article interactions (tags) to be sent.
    ///   - completion: A completion handler that will be called with result.
    func uploadTaggings(_ taggings: [Tagging], completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>)

    /// This method downloads all user extensions.
    /// - Parameters:
    ///   - after: The pagination cursor from which the pagination should start.
    ///   - completion:  A completion handler that will be called with result.
    func getCurrentUserExtensions(after: PaginationCursor?, completion: @escaping Completion<Page<Extension>?, NetworkError<EmptyAPIError>>)

    /// This method updates or create an extension.
    /// - Parameters:
    ///   - section: The section which the extension belongs to.
    ///   - text: The extension content.
    ///   - completion: A completion handler that will be called with result.
    func updateExtension(section: LearningCardSectionIdentifier, text: String, completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>)

    // This method gets users who share notes with the current user.
    /// - Parameters:
    ///   - completion:  A completion handler that will be called with result.
    func getUsersWhoShareExtensionsWithCurrentUser(completion: @escaping Completion<[User], NetworkError<EmptyAPIError>>)

    // This method downloads the extensions of a certain user.
    /// - Parameters:
    ///   - userIdentifier: The identifier of the user we are requesting extensions for.
    ///   - after: The pagination cursor from which the pagination should start.
    ///   - completion:  A completion handler that will be called with result.
    func getExtensions(for userIdentifier: UserIdentifier, after: PaginationCursor?, completion: @escaping Completion<Page<Extension>?, NetworkError<EmptyAPIError>>)

    /// This method returns the list of targets and the user's access to them (permissions).
    /// - Parameter completion: A completion handler that will carry the target access items.
    func getTargetAccesses(completion: @escaping Completion<[TargetAccess], NetworkError<EmptyAPIError>>)

    /// This method uploads all readings.
    /// - Parameters:
    ///   - readings: Learning card readings which are stored in the `ReadingRepository`.
    ///   - completion: A completion handler that will be called with result.
    func uploadReadings(_ readings: [LearningCardReading], completion: @escaping Completion<Void, NetworkError<EmptyAPIError>>)

}

public protocol DownloadDelegate: AnyObject {
    func downloadClientDidMakeProgress(source: URL, progress: Double)
    func downloadClientDidFinish(source: URL, destination: URL)
    func downloadClientDidFail(source: URL, error: Error)
    func downloadClientDidFinishEventsForBackgroundURLSession()
}
