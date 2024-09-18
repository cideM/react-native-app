//
//  Tracker.Event.Library.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

extension Tracker.Event {

    enum Library {

        case libraryUpdateSkipped(inactiveDays: Int)

        case libraryInstallStarted(isFirstInstall: Bool, libraryType: LibraryType)

        case libraryUnzipStarted(isFirstInstall: Bool, libraryType: LibraryType)
        case libraryUnzipCompleted(isFirstInstall: Bool, libraryType: LibraryType)
        case libraryUnzipFailed(isFirstInstall: Bool, libraryType: LibraryType, error: Error)

        case libraryInstallFailed(isFirstInstall: Bool, libraryType: LibraryType, error: Error)
        case libraryInstallCompleted(isFirstInstall: Bool, newLibraryVersion: String, libraryType: LibraryType)

        case libraryUpdateStarted(isUpdateUserTriggered: Bool, libraryType: LibraryType)
        case libUpdateCheckStart(isUpdateUserTriggered: Bool, libraryType: LibraryType)
        case libUpdateAvailable(isUpdateUserTriggered: Bool, newLibraryVersion: String, updateMode: LibraryUpdateMode? = nil, libraryType: LibraryType)
        case libUpdateCheckFailed(isUpdateUserTriggered: Bool, newLibraryVersion: String? = nil, updateMode: LibraryUpdateMode? = nil, libraryType: LibraryType, error: Error)

        case libraryDownloadStarted(isUpdateUserTriggered: Bool, newLibraryVersion: String, updateMode: LibraryUpdateMode? = nil, libraryType: LibraryType)
        case libraryDownloadCompleted(libraryType: LibraryType)
        case libraryDownloadFailed(libraryType: LibraryType, error: Error)

        case libraryUpdateCompleted(isFirstInstall: Bool, newLibraryVersion: String, updateMode: LibraryUpdateMode? = nil, libraryType: LibraryType)

        case libraryUpdateSettingsToggled(isBackgroundUpdatesEnabled: Bool, libraryType: LibraryType)
    }

    // The type that is being downloaded.
    // Either `Articles archive` or `Pharma database`.
    enum LibraryType: String {
        case articles
        case pharma
    }
}
