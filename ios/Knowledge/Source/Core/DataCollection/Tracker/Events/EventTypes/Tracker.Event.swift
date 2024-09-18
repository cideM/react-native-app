//
//  Event.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 30.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension Tracker {
    enum Event {
        case appLifecycle(AppLifecycle)
        case settings(Settings)
        case signupAndLogin(SignupAndLogin)
        case library(Library)
        case inAppPurchase(InAppPurchase)
        case search(Search)
        case article(Article)
        case pharma(Pharma)
        case monograph(Monograph)
        case media(Media)
        case siri(Siri)
        case dashboard(Dashboard)
    }
}
