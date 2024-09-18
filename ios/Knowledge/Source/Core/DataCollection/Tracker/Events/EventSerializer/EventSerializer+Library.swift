//
//  SegmentTrackingSerializer+Library.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.Library) -> String? {
        switch event {
        case .libraryUpdateSkipped: return "library_update_skipped"
        case .libraryInstallStarted: return "library_install_started"
        case .libraryUnzipStarted: return "library_unzip_started"
        case .libraryUnzipCompleted: return "library_unzip_completed"
        case .libraryUnzipFailed: return "library_unzip_failed"
        case .libraryInstallFailed: return "library_install_failed"
        case .libraryInstallCompleted: return "library_install_completed"
        case .libraryUpdateStarted: return "library_update_started"
        case .libUpdateCheckStart: return "lib_update_check_start"
        case .libUpdateAvailable: return "lib_update_available"
        case .libUpdateCheckFailed: return "lib_update_check_failed"
        case .libraryDownloadStarted: return "library_download_started"
        case .libraryDownloadCompleted: return "library_download_completed"
        case .libraryDownloadFailed: return "library_download_failed"
        case .libraryUpdateCompleted: return "library_update_completed"
        case .libraryUpdateSettingsToggled: return "library_update_settings_toggled"
        }
    }

    func parameters(for event: Tracker.Event.Library) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Library>()
        switch event {
        case .libraryUpdateSkipped(let count):
            parameters.set(count, for: .inactiveDays)

        case .libraryInstallStarted(let isFirstInstall, let libraryType),
             .libraryUnzipStarted(let isFirstInstall, let libraryType),
             .libraryUnzipCompleted(let isFirstInstall, let libraryType):
            parameters.set(isFirstInstall, for: .isFirstInstall)
            parameters.set(libraryType.rawValue, for: .library)

        case .libraryUnzipFailed(let isFirstInstall, let libraryType, let error),
             .libraryInstallFailed(let isFirstInstall, let libraryType, let error):
            parameters.set(isFirstInstall, for: .isFirstInstall)
            parameters.set(libraryType.rawValue, for: .library)
            parameters.set(error, for: .errorMessage)

        case .libraryUpdateStarted(let isUpdateUserTriggered, let libraryType),
             .libUpdateCheckStart(let isUpdateUserTriggered, let libraryType):
            parameters.set(isUpdateUserTriggered ? "manual" : "automatic", for: .updateType)
            parameters.set(libraryType.rawValue, for: .library)

        case .libraryInstallCompleted(let isFirstInstall, let newLibraryVersion, let libraryType):
            parameters.set(isFirstInstall, for: .isFirstInstall)
            parameters.set(newLibraryVersion, for: .libraryNewVersion)
            parameters.set(libraryType.rawValue, for: .library)

        case .libraryUpdateCompleted(let isFirstInstall, let newLibraryVersion, let updateMode, let libraryType):
            parameters.set(isFirstInstall, for: .isFirstInstall)
            parameters.set(newLibraryVersion, for: .libraryNewVersion)
            parameters.set(updateMode?.rawValue, for: .updateMode)
            parameters.set(libraryType, for: .library)

        case .libUpdateAvailable(let isUpdateUserTriggered, let newLibraryVersion, let updateMode, let libraryType),
             .libraryDownloadStarted(let isUpdateUserTriggered, let newLibraryVersion, let updateMode, let libraryType):
            parameters.set(isUpdateUserTriggered ? "manual" : "automatic", for: .updateType)
            parameters.set(newLibraryVersion, for: .libraryNewVersion)
            parameters.set(updateMode?.rawValue, for: .updateMode)
            parameters.set(libraryType, for: .library)

        case .libUpdateCheckFailed(let isUpdateUserTriggered, let newLibraryVersion, let updateMode, let libraryType, let error):
            parameters.set(isUpdateUserTriggered ? "manual" : "automatic", for: .updateType)
            parameters.set(error, for: .errorMessage)
            parameters.set(newLibraryVersion, for: .libraryNewVersion)
            parameters.set(updateMode?.rawValue, for: .updateMode)
            parameters.set(libraryType, for: .library)

        case .libraryDownloadFailed(let libraryType, let error):
            parameters.set(libraryType, for: .library)
            parameters.set(error, for: .errorMessage)

        case .libraryDownloadCompleted(let libraryType):
            parameters.set(libraryType, for: .library)

        case .libraryUpdateSettingsToggled(let isBackgroundUpdatesEnabled, let libraryType):
            parameters.set(isBackgroundUpdatesEnabled ? "activated" : "deactivated", for: .updateSetting)
            parameters.set(libraryType, for: .library)
        }
        return parameters.data
    }
}

extension SegmentParameter {
    enum Library: String {
        case isFirstInstall = "is_first_install"
        case updateType = "update_type"
        case updateMode = "update_mode"
        case libraryNewVersion = "library_new_version"
        case updateSetting = "update_setting"
        case errorMessage = "error_message"
        case library = "library"
        case inactiveDays = "inactive_days"
    }
}
