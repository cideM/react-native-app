//
//  Tracker.Event.SignupAndLogin.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 15.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {

    enum SignupAndLogin {
        case clearEmail(locatedOn: Screen)
        case contactAmboss(locatedOn: Screen)
        case dashboardPageLoaded
        case emailConfirmationModalClosed
        case emailConfirmationModalShown
        case emailSubmitted(email: String)
        case firstLoginCompleted(email: String)
        case firstOpen
        case forgotPasswordClicked(locatedOn: Screen)
        case registerSuccess(email: String, region: String, stage: UserStage)
        case loginButtonClicked
        case loginCompleted(email: String)
        case loginFailed(errorMessage: String)
        case loginInitiated(email: String)
        case openPrivacy(locatedOn: Screen)
        case openTerms(locatedOn: Screen)
        case passwordSubmitted(email: String)
        case physiciansDisclaimerAccepted
        case physiciansDisclaimerModalShown
        case physiciansDisclaimerRejected
        case setEmailScreenShown
        case setPasswordScreenShown
        case signUpButtonClicked
        case signUpEmailAlreadyTaken(email: String)
        case togglePasswordVisiblity(locatedOn: Screen, status: Status)
        case userStageSelected(stage: UserStage, referer: Referer)
        case userStageSelectionShown(referer: Referer)
        case userStageSubmitted(stage: UserStage, referer: Referer)
        case welcomeScreenShown
        case loginScreenShown
    }
}

extension Tracker.Event.SignupAndLogin {

    enum Status {
        case visible
        case invisible
    }
    enum Stage: Int {
        case clinic = 2
        case physician = 4
        case preclinic = 1
    }

    enum UserStage: String {
        case clinic = "Clinic"
        case physician = "Physician"
        case preclinic = "Preclinic"

        var intValue: Int {
            switch self {
            case .preclinic: return 1
            case .clinic: return 2
            case .physician: return 4
            }
        }
    }

    enum Referer: String {
        case signup = "signup"
        case settings = "settings"
        case dashboard = "dashboard"
        case articleSettings = "article_settings"
    }
}
