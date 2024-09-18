//
//  SegmentTrackingSerializer.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 17.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

/// This is more or less just a proxy class that provides basic structs required for the logic
/// and forwards the creation of event names and properties to the resoponsible extension
class EventSerializer {

    func name(for event: Tracker.Event) -> String? {
        switch event {
        case .appLifecycle(let event): return name(for: event)
        case .settings(let event): return name(for: event)
        case .signupAndLogin(let event): return name(for: event)
        case .library(let event): return name(for: event)
        case .article(let event): return name(for: event)
        case .inAppPurchase(let event): return name(for: event)
        case .search(let event): return name(for: event)
        case .pharma(let event): return name(for: event)
        case .monograph(let event): return name(for: event)
        case .media(let event): return name(for: event)
        case .siri(let event):  return name(for: event)
        case .dashboard(let event): return name(for: event)
        }
    }

    func parameters(for event: Tracker.Event) -> [String: Any]? {
        switch event {
        case .appLifecycle(let event): return parameters(for: event)
        case .settings(let event): return parameters(for: event)
        case .signupAndLogin(let event): return parameters(for: event)
        case .library(let event): return parameters(for: event)
        case .article(let event): return parameters(for: event)
        case .inAppPurchase(let event): return parameters(for: event)
        case .search(let event): return parameters(for: event)
        case .pharma(let event): return parameters(for: event)
        case .monograph(let event): return parameters(for: event)
        case .media(let event): return parameters(for: event)
        case .siri(let event):  return parameters(for: event)
        case .dashboard(let event): return parameters(for: event)
        }
    }
}
