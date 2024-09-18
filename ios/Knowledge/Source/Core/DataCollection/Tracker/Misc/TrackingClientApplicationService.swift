//
//  TrackingClientApplicationService.swift
//  Knowledge
//
//  Created by CSH on 23.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import UIKit

final class TrackingClientApplicationService: ApplicationService {

    @Inject var tracker: TrackingType
    @Inject var deviceSettingsRepository: DeviceSettingsRepositoryType
    private var authorizationDidInvalidateNotification: NSObjectProtocol?
    private var authorizationDidChangeNotificationObserver: NSObjectProtocol?
    private var userStageDidChangeNotificationObserver: NSObjectProtocol?
    private var studyObjectiveDidChangeNotificationObserver: NSObjectProtocol?
    private var libraryRepositoryDidInitializeNotification: NSObjectProtocol?
    private var libraryDidChangeNotificationObserver: NSObjectProtocol?
    private var featureFlagsDidChangeNotificationObserver: NSObjectProtocol?

    func application(_ application: UIApplicationType,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUserProperties()
        registerAuthorizationInvalidationLogging()
        tracker.track(.applicationStarted(appAppearancePreference: deviceSettingsRepository.currentUserInterfaceStyle.trackingPreference(),
                                          systemAppearancePreference: UIScreen.main.traitCollection.userInterfaceStyle.trackingSystemPreference()))
        return true
    }

    private func registerAuthorizationInvalidationLogging(logger: Monitoring = resolve()) {
        enum AuthorizationDidInvalidateError: Error {
            case authorizationDidInvalidateError(String)
        }
        authorizationDidInvalidateNotification = NotificationCenter.default.observe(for: AuthorizationDidInvalidateNotification.self,
                                                                                    object: nil,
                                                                                    queue: .main) { notification in
            let error = AuthorizationDidInvalidateError.authorizationDidInvalidateError(notification.developerDescription)
            logger.error(error, context: .system)
        }
    }

    private func setUserProperties(authorizationRepository: AuthorizationRepositoryType = resolve(),
                                   userDataRepository: UserDataRepositoryType = resolve(),
                                   featureFlagRepository: FeatureFlagRepositoryType = resolve(),
                                   libraryRepository: LibraryRepositoryType = resolve()) {
        tracker.set([.variant(AppConfiguration.shared.appVariant),
                     .user(authorizationRepository.authorization?.user),
                     .deviceId(authorizationRepository.deviceId),
                     .stage(userDataRepository.userStage),
                     .studyObjective(userDataRepository.studyObjective),
                     .libraryMetadata(libraryRepository.library.metadata),
                     .features(featureFlagRepository.featureFlags)
        ])

        authorizationDidChangeNotificationObserver = NotificationCenter.default.observe(for: AuthorizationDidChangeNotification.self,
                                                                                        object: nil,
                                                                                        queue: .main) { [weak self] change in
            self?.tracker.update(.user(change.newValue?.user))
        }

        userStageDidChangeNotificationObserver = NotificationCenter.default.observe(for: UserStageDidChangeNotification.self,
                                                                                    object: userDataRepository,
                                                                                    queue: .main) { [weak self] change in
            self?.tracker.update(.stage(change.newValue))
        }

        studyObjectiveDidChangeNotificationObserver = NotificationCenter.default.observe(for: StudyObjectiveDidChangeNotification.self,
                                                                                         object: userDataRepository,
                                                                                         queue: .main) { [weak self] change in
            self?.tracker.update(.studyObjective(change.newValue))
        }

        libraryRepositoryDidInitializeNotification = NotificationCenter.default.observe(for: LibraryRepositoryDidInitializeNotification.self,
                                                                                        object: nil,
                                                                                        queue: .main) { [weak self] change in
            self?.tracker.update(.libraryMetadata(change.libraryRepository.library.metadata))

            self?.libraryDidChangeNotificationObserver = NotificationCenter.default.observe(for: LibraryDidChangeNotification.self,
                                                                                            object: change.libraryRepository,
                                                                                            queue: .main) { [weak self] change in
                self?.tracker.update(.libraryMetadata(change.newValue.metadata))
            }
        }

        featureFlagsDidChangeNotificationObserver = NotificationCenter.default.observe(for: FeatureFlagsDidChangeNotification.self,
                                                                                       object: featureFlagRepository,
                                                                                       queue: .main) { [weak self] change in
            self?.tracker.update(.features(change.newValue))
        }
    }
}
