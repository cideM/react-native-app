//
//  SegmentTrackingSerializer+SignupAndLogin.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func name(for event: Tracker.Event.SignupAndLogin) -> String? {
        switch event {
        case .clearEmail: return "clear_email"
        case .contactAmboss: return "contact_amboss"
        case .dashboardPageLoaded: return "dashboard_page_loaded"
        case .emailConfirmationModalClosed: return "email_confirmation_modal_closed"
        case .emailConfirmationModalShown: return "email_confirmation_modal_shown"
        case .emailSubmitted: return "email_submitted"
        case .registerSuccess: return "register_success"
        case .firstLoginCompleted: return "first_login_completed"
        case .firstOpen: return "first_open"
        case .forgotPasswordClicked: return "forgot_password_clicked"
        case .loginButtonClicked: return "login_button_clicked"
        case .loginCompleted: return "login_completed"
        case .loginFailed: return "login_failed"
        case .loginInitiated: return "login_initiated"
        case .openPrivacy: return "open_privacy"
        case .openTerms: return "open_terms"
        case .passwordSubmitted: return "password_submitted"
        case .physiciansDisclaimerAccepted: return "physicians_disclaimer_accepted"
        case .physiciansDisclaimerModalShown: return "physicians_disclaimer_modal_shown"
        case .physiciansDisclaimerRejected: return "physicians_disclaimer_rejected"
        case .setEmailScreenShown: return "set_email_screen_shown"
        case .setPasswordScreenShown: return "set_password_screen_shown"
        case .signUpButtonClicked: return "sign_up_button_clicked"
        case .signUpEmailAlreadyTaken: return "sign_up_email_already_taken"
        case .togglePasswordVisiblity: return "toggle_password_visiblity"
        case .userStageSelected: return "user_stage_selected"
        case .userStageSelectionShown: return "user_stage_selection_shown"
        case .userStageSubmitted: return "user_stage_submitted"
        case .welcomeScreenShown: return "welcome_screen_shown"
        case .loginScreenShown: return "login_screen_shown"
        }
    }

    func parameters(for event: Tracker.Event.SignupAndLogin) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.LoginAndSignup>()
        switch event {
        case .firstOpen,
             .emailConfirmationModalClosed,
             .dashboardPageLoaded,
             .emailConfirmationModalShown,
             .loginButtonClicked,
             .physiciansDisclaimerAccepted,
             .physiciansDisclaimerModalShown,
             .physiciansDisclaimerRejected,
             .setEmailScreenShown,
             .setPasswordScreenShown,
             .signUpButtonClicked,
             .welcomeScreenShown,
             .loginScreenShown:
            return nil

        case .firstLoginCompleted(let email),
             .emailSubmitted(let email),
             .loginCompleted(let email),
             .loginInitiated(let email),
             .signUpEmailAlreadyTaken(let email):
            parameters.set(email, for: .email)

        case .forgotPasswordClicked(let screen),
             .clearEmail(let screen),
             .contactAmboss(let screen),
             .openPrivacy(let screen),
             .openTerms(let screen):
            parameters.set(value(for: screen), for: .locatedOn)

        case .loginFailed(let errorMessage):
            parameters.set(errorMessage, for: .errorMessage)

        case .passwordSubmitted(let email):
            parameters.set(email, for: .email)

        case .togglePasswordVisiblity(let screen, let status):
            parameters.set(value(for: screen), for: .locatedOn)
            parameters.set(value(for: status), for: .status)

        case .userStageSelectionShown(let referer):
            parameters.set(referer, for: .referer)

        case .userStageSelected(let stage, let referer),
             .userStageSubmitted(let stage, let referer):
            parameters.set(stage, for: .userStage)
            parameters.set(referer, for: .referer)
        case .registerSuccess(let email, let region, let stage):
            parameters.set(email, for: .email)
            parameters.set(region, for: .region)
            parameters.set(stage.intValue, for: .stage)
        }

        return parameters.data
    }

    private func value(for status: Tracker.Event.SignupAndLogin.Status) -> String {
        switch status {
        case .invisible: return "invisible"
        case .visible: return "visible"
        }
    }

    private func value(for parameter: Tracker.Event.Screen) -> String {
        switch parameter {
        case .login: return "login_screen"
        case .setEmail: return "set_email_screen"
        case .setPassword: return  "set_password_screen"
        case .search: return "search_screen"
        case .article: return "article_search"
        }
    }
}

extension SegmentParameter {
    enum LoginAndSignup: String {
        case locatedOn = "located_on"
        case email
        case region
        case status
        case stage
        case userStage = "user_stage"
        case referer = "referer"
        case errorMessage = "error_message"
    }
}
