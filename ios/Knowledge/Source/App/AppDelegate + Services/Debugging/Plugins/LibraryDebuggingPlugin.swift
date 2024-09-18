//
//  LibraryDebuggingPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 23.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//
// swiftlint:disable force_try

#if Debug || QA

import Common
import DIKit
import Domain
import UIKit

class LibraryDebuggingPlugin: DebuggerPlugin {
    let title = "Library Debugging"
    let description: String? = "Can be used to replaced the currently installed learning card library with a partial archive"

    var libraryDescription: String {
        """
        Version: \(libraryRepository.library.metadata.versionId)
        Filename: \(libraryRepository.library.url.lastPathComponent)
        """
    }

    @Inject private var libraryRepository: LibraryRepositoryType
    @Inject(tag: DIKitTag.URL.libraryRoot) private var libraryBaseUrl: URL
    @Inject(tag: DIKitTag.URL.partialArchive) private var partialArchiveUrl: URL

    func viewController() -> UIViewController {
        let errorViewController = UIViewController()
        let presenter = SubviewMessagePresenter(rootView: errorViewController.view)
        presenter.present(PresentableMessage(title: "Library", description: libraryDescription, logLevel: .debug), actions: [
            MessageAction(title: "Replace with Partial Archive", style: .primary) { [weak self] in
                guard let self = self else { return false }
                let tmpFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try! FileManager.default.copyItem(at: self.partialArchiveUrl, to: tmpFileUrl)
                let library = try! Library(with: tmpFileUrl)
                library.move(toParent: self.libraryBaseUrl)
                self.libraryRepository.library = library
                return false // -> do not remove the presenting view when done, if you do debugger overlay turns "transparent"
            }
        ])
        errorViewController.title = "Library"
        return errorViewController
    }
}
#endif
// swiftlint:enable force_try
