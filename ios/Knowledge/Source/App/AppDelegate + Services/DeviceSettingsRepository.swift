//
//  DeviceSettingsRepository.swift
//  Knowledge
//
//  Created by Silvio Bulla on 28.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol DeviceSettingsRepositoryType: AnyObject {
    var keepScreenOn: Bool { get set }
    var currentFontScale: Float { get set }
    var currentUserInterfaceStyle: UIUserInterfaceStyle { get set }
}

final class DeviceSettingsRepository: DeviceSettingsRepositoryType {

    var keepScreenOn: Bool {
        get {
            storage.get(for: .keepScreenOn) ?? true
        }
        set {
            storage.store(newValue, for: .keepScreenOn)
        }
    }

    var currentFontScale: Float {
        get {
            storage.get(for: .currentFontScale) ?? defaultFontScale
        }
        set {
            let oldValue = currentFontScale
            storage.store(newValue, for: .currentFontScale)
            NotificationCenter.default.post(FontSizeDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var currentUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            if let intValue: Int = storage.get(for: .currentUserInterfaceStyle) {
                return UIUserInterfaceStyle(rawValue: intValue) ?? defaultUserInterfaceStyle
            }
            return defaultUserInterfaceStyle
        }
        set {
            storage.store(newValue.rawValue, for: .currentUserInterfaceStyle)
            NotificationCenter.default.post(UserInterfaceStyleChangedNotification(style: newValue), sender: self)
        }
    }

    private let storage: Storage
    private let defaultFontScale: Float = 1
    private let defaultUserInterfaceStyle: UIUserInterfaceStyle = .unspecified
    private var authorizationDidChangeObserver: NSObjectProtocol?

    init(storage: Storage) {
        self.storage = storage

        authorizationDidChangeObserver = NotificationCenter.default.observe(for: AuthorizationDidChangeNotification.self, object: nil, queue: .main) { [weak self] authorization in
            guard let self = self, authorization.newValue == nil else { return }
            self.keepScreenOn = true
            self.currentFontScale = self.defaultFontScale
        }
    }
}
