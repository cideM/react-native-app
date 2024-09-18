//
//  DependencyContainer+PharmaLibrary.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import DIKit

import Domain
import PharmaDatabase

extension DependencyContainer {
    @Inject static var monitor: Monitoring
    private static let pharmaDatabaseApplicationService: PharmaDatabaseApplicationService? = {
        switch AppConfiguration.shared.appVariant {
        case .knowledge:
            break

        case .wissen:
            do {
                if var workingDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
                    let version = Version(major: PharmaDatabase.supportedMajorSchemaVersion, minor: 0, patch: 0)
                    let updaterWorkingDirectory = PharmaDatabaseApplicationService.root(in: workingDirectory)
                    let updater = try PharmaUpdater(workingDirectory: updaterWorkingDirectory, unzipper: Unzipper(), pharmaDownloader: try FileDownloader(), currentVersion: version)
                    let service = try PharmaDatabaseApplicationService(updater: updater, workingDirectory: workingDirectory, storage: shared.resolve(tag: DIKitTag.Storage.default))
                    return service
                }
            } catch {
                monitor.error(error, context: .pharma)
            }
        }
        return nil
    }()

    static var pharmaDatabase = module {
        factory { pharmaDatabaseApplicationService as PharmaDatabaseApplicationServiceType? }
    }
}
