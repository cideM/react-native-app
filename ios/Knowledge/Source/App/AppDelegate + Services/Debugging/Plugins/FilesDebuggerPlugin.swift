//
//  FilesDebuggerPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 28.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import DeveloperOverlay
import UIKit

class FilesDebuggerPlugin: DebuggerPlugin {
    static let appSandboxDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("..") // swiftlint:disable:this force_unwrapping
    static let logsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Logs") // swiftlint:disable:this force_unwrapping

    let url: URL
    let title: String
    let description: String?

    init(path url: URL, title: String = "Files", description: String? = "This plugin can take a few seconds to load and freezes the screen during that time.") {
        self.url = url
        self.title = title
        self.description = description
    }

    func viewController() -> UIViewController {
        let fileDebugger = FileInspectorViewController(basePath: url)
        fileDebugger.title = title
        return fileDebugger
    }

}

#endif
