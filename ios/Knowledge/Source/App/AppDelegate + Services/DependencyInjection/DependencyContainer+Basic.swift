//
//  DependencyContainer+Basic.swift
//  Knowledge
//
//  Created by CSH on 13.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Domain
import Foundation

extension DependencyContainer {
    static var basic = module {
        single { multiMonitor as Monitoring }
        single {
            MultiTracer(tracers: [
                FirebaseTracer(),
                LogTracer(),
                SignpostTracer(subsystem: Bundle.main.bundleIdentifier ?? "knowledge")
            ]) as Tracer
        }
    }

    #if DEBUG
    private static let monitors: [Monitoring] = [OSLogMonitor()]
    #else
    private static let monitors: [Monitoring] = [OSLogMonitor(), tracking.resolve() as CrashlyticsMonitor]
    #endif
    private static let multiMonitor = MultiMonitor(with: monitors)
}
