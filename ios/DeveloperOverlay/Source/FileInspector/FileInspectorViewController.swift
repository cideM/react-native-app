//
//  FileInspectorViewController.swift
//  DeveloperOverlay
//
//  Created by CSH on 25.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class FileInspectorViewController: UITableViewController {

    private let fileSizeFormatter = ByteCountFormatter()

    public struct Child {
        let url: URL
        let creationDate: String?
        let isFolder: Bool

        init(url: URL, creationDate: String?) {
            self.url = url
            self.creationDate = creationDate
            self.isFolder = FileInspectorViewController.isDirectory(url)
        }
    }

    let basePath: URL
    let childs: [Child]

    public convenience init(basePath: URL) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withFullDate
        let childs = FileInspectorViewController.filesAndFolders(in: basePath)
            .map { url -> Child in
                if let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
                    return Child(url: url, creationDate: dateFormatter.string(from: creationDate))
                }
                return Child(url: url, creationDate: nil)
            }
            .sorted { $0.url.lastPathComponent > $1.url.lastPathComponent }
        self.init(basePath: basePath, childs: childs)
    }

    public init(basePath: URL, childs: [Child]) {
        self.basePath = basePath
        self.childs = childs
        super.init(style: .plain)
        self.title = basePath.lastPathComponent
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        childs.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let child = self.child(at: indexPath)
        cell.textLabel?.text = child.url.lastPathComponent
        cell.textLabel?.numberOfLines = 2
        cell.accessoryType = child.isFolder ? .disclosureIndicator : .none
        if let size = try? FileInspectorViewController.size(at: child.url) {
            let creationDate = child.creationDate ?? "nil"
            cell.detailTextLabel?.text = "\(fileSizeFormatter.string(fromByteCount: Int64(size))) - \(creationDate)"
        } else {
            cell.detailTextLabel?.text = nil
        }
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let child = self.child(at: indexPath)
        if child.isFolder {
            let viewController = FileInspectorViewController(basePath: child.url)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let documentInteractionController = UIDocumentInteractionController(url: child.url)
            documentInteractionController.delegate = self
            documentInteractionController.presentPreview(animated: true)
        }
    }

    private func child(at indexPath: IndexPath) -> Child {
        guard indexPath.row < childs.count else {
            fatalError("Index out of bounds")
        }
        return childs[indexPath.row]
    }

    private static func size(at url: URL) throws -> UInt64 {
        if isDirectory(url) {
            return try foldersize(at: url)
        } else {
            return try filesize(at: url)
        }
    }

    private static func filesize(at url: URL) throws -> UInt64 {

        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey
        ]
        let resourceValues = try url.resourceValues(forKeys: allocatedSizeResourceKeys)

        guard resourceValues.isRegularFile ?? false else {
            return 0
        }

        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

    private static func foldersize(at url: URL) throws -> UInt64 {
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey
        ]

        let enumerator = FileManager.default.enumerator(at: url,
                                                        includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                        options: [])! // swiftlint:disable:this force_unwrapping

        let size = try enumerator.compactMap { $0 as? URL }
            .reduce(into: 0) { size, url in
                size += try FileInspectorViewController.filesize(at: url)
            }

        return size
    }

    private static func isDirectory(_ url: URL) -> Bool {
        let attributes = try? url.resourceValues(forKeys: [.isDirectoryKey])
        return attributes?.isDirectory ?? false
    }

}

extension FileInspectorViewController: UIDocumentInteractionControllerDelegate {
    // unused:ignore documentInteractionControllerViewControllerForPreview
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        self
    }
}

extension FileInspectorViewController {
    static func filesAndFolders(in folder: URL) -> [URL] {
        let fileManager = FileManager.default
        let filesAndFolders = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey, URLResourceKey.creationDateKey], options: [])
        return filesAndFolders ?? []
    }
}
