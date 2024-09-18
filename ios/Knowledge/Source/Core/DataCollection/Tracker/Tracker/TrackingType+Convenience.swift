//
//  EventTrackingType+Convinience.swift
//  Knowledge
//
//  Created by Elmar Tampe on 14.07.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

// Convenience wrapper
extension TrackingType {
    func track(_ event: Tracker.Event.AppLifecycle) {
        track(Tracker.Event.appLifecycle(event))
    }
    func track(_ event: Tracker.Event.Settings) {
        track(Tracker.Event.settings(event))
    }
    func track(_ event: Tracker.Event.SignupAndLogin) {
        track(Tracker.Event.signupAndLogin(event))
    }
    func track(_ event: Tracker.Event.Library) {
        track(Tracker.Event.library(event))
    }
    func track(_ event: Tracker.Event.InAppPurchase) {
        track(Tracker.Event.inAppPurchase(event))
    }
    func track(_ event: Tracker.Event.Search) {
        track(Tracker.Event.search(event))
    }
    func track(_ event: Tracker.Event.Pharma) {
        track(Tracker.Event.pharma(event))
    }
    func track(_ event: Tracker.Event.Monograph) {
        track(Tracker.Event.monograph(event))
    }
    func track(_ event: Tracker.Event.Article) {
        track(Tracker.Event.article(event))
    }
    func track(_ event: Tracker.Event.Media) {
        track(Tracker.Event.media(event))
    }
    func track(_ event: Tracker.Event.Siri) {
        track(Tracker.Event.siri(event))
    }
    func track(_ event: Tracker.Event.Dashboard) {
        track(Tracker.Event.dashboard(event))
    }
}
