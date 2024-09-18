//
//  ConsentApplicationServiceType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

/// @mockable
protocol ConsentApplicationServiceType: AnyObject, ApplicationService {
    /// Shows the consent information collection dialog if the user hasn't provided the information yet.
    func showConsentDialogIfNeeded()

    /// Show the settings screen of the Consent Management Platform.
    func showConsentSettings()

    /// Resets the SDK to a configured initial state.
    func reset()

    /// Indicates if consent dialog was presented to the user
    /// Usually it does not come up a second time
    var initialConsentDialogWasShown: Bool { get set }

    func setViewDismissalCompletion(completion: ((Bool) -> Void)?)
}
