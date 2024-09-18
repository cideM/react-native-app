//
//  ZipLibrary.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 23.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import ZIPFoundation
import ZippyJSON
import Foundation

/// This class is responsible for all `Library` related access.
final class Library: LibraryType {

    private var _metadata: LibraryMetadata?
    var metadata: LibraryMetadata {
        if let metadata = _metadata {
            return metadata
        }
        // Defaulting the version to "0" should be ok because:
        // Something is broken in case this happens (it should not).
        // Querying the server with version zero will return the latest update.
        // Which then hopefully gets downloaded and fixes whatever is wrong here ...
        var versionString = "0"
        if let versionData = try? archive.data(from: entryCache["VERSION"]) {
            versionString = String(decoding: versionData, as: UTF8.self)
        }
        let hasContent = entryCache.keys.contains { $0.hasPrefix("cards/") && $0.hasSuffix(".html") }

        var createdAt: Date?
        if let date = entryCache["VERSION"]?.fileAttributes[.modificationDate] as? Date {
           createdAt = date
        }

        var isDarkModeSupported = false
        if
            let data = try? archive.data(from: entryCache["css/mobile.css"]),
            let css = String(data: data, encoding: .utf8) {
            isDarkModeSupported = css.contains("color-scheme:light dark")
        }

        let metadata = LibraryMetadata(
            versionString: versionString,
            containsLearningCardContent: hasContent,
            createdAt: createdAt,
            isDarkModeSupported: isDarkModeSupported)

        _metadata = metadata
        return metadata
    }

    let autolinks: [Autolink]
    let learningCardTreeItems: [LearningCardTreeItem]

    private let snippets: [Snippet]

    private let archive: Archive
    private let entryCache: [String: Entry]

    private let learningCardMetaItems: [LearningCardMetaItem]
    private let imageResources: [ImageResourceType]

    private let tracer: Tracer = resolve()

    required init(with zip: URL) throws {
        self.url = zip

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LibraryError.missingArchive(url: url)
        }

        let trace = tracer.startedTrace(name: "Library.init", context: .library)
        defer { trace.stop() }

        guard let archive = try? Archive(url: url, accessMode: .read, pathEncoding: nil) else {
            throw LibraryError.invalidArchive(url: url)
        }
        self.archive = archive

        let entryCache = tracer.trace(name: "Library.init.entryCache", context: .library) {
            archive.reduce(into: [String: Entry]()) { cache, entry in cache[entry.path] = entry }
        }
        self.entryCache = entryCache

        self.autolinks = try tracer.trace(name: "autolinks.json", context: .library) {
            try archive.object(from: entryCache["autolinks.json"])
        }
        self.snippets = try tracer.trace(name: "snippets.json", context: .library) {
            try archive.object(from: entryCache["snippets.json"])
        }
        self.learningCardTreeItems = try tracer.trace(name: "lctree.json", context: .library) {
            try archive.object(from: entryCache["lctree.json"])
        }
        self.learningCardMetaItems = try tracer.trace(name: "lcmeta.json", context: .library) {
            try archive.object(from: entryCache["lcmeta.json"])
        }
        self.imageResources = try tracer.trace(name: "imageresources.json", context: .library) {
            try archive.object(from: entryCache["imageresources.json"])
        }
    }

    var url: URL

    func move(toParent folder: URL) {
        move(toParent: folder, retries: 5)
    }

    func gallery(with identifier: GalleryIdentifier) throws -> Gallery {
        if let gallery = learningCardMetaItems.lazy.flatMap({ $0.galleries }).first(where: { $0.id == identifier }) {
            return gallery
        } else {
            throw LibraryError.missingGallery(identifier: identifier)
        }
    }

    func imageResource(for identifier: ImageResourceIdentifier) throws -> ImageResourceType {
        if let imageResource = imageResources.first(where: { $0.imageResourceIdentifier == identifier }) {
            return imageResource
        } else {
            throw LibraryError.missingImageResource(identifier: identifier)
        }
    }

    func snippet(for learningCardDeeplink: LearningCardDeeplink) throws -> Snippet? {
        snippets.first { $0.destinations.contains { $0.articleEid == learningCardDeeplink.learningCard && ($0.anchor) as LearningCardAnchorIdentifier? == learningCardDeeplink.anchor } }
    }

    func snippet(withIdentifier identifier: SnippetIdentifier) throws -> Snippet? {
        snippets.first { $0.identifier == identifier }
    }

    func learningCardMetaItem(for identifier: LearningCardIdentifier) throws -> LearningCardMetaItem {
        if let item = learningCardMetaItems.first(where: { $0.learningCardIdentifier == identifier }) {
            return item
        } else {
            throw LibraryError.missingLearningCard(identifier: identifier)
        }
    }
    func learningCardHtmlBody(for learningCard: LearningCardIdentifier) throws -> String {
        let data = try archive.data(from: entryCache["cards/\(learningCard.value).html"])
        return String(data: data, encoding: .utf8) ?? ""
    }

    func data(at path: String) throws -> Data {
        try archive.data(from: entryCache[path.trimmingCharacters(in: ["/"])])
    }
}

fileprivate extension Library {

    private func move(toParent folder: URL, retries: Int) {
        do {
            let newUrl = folder.appendingPathComponent(UUID().uuidString)
            try FileManager.default.moveItem(at: url, to: newUrl)
            url = newUrl
        } catch {
            if retries > 0 {
                move(toParent: folder, retries: retries - 1)
            } else {
                fatalError("\(error.localizedDescription)")
            }
        }
    }
}
