//
//  AppConfiguration+Tracking.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

extension AppConfiguration: TrackingConfiguration {

    // MARK: - Segment
    var segmentAnalyticsWriteKey: String {
#if DEBUG || QA
        return "kOBuDEcYdc5kkCPkH3nKp2awzAkJqYBg"
#else
        return "9CmtA9DrxNhF1T7sLmSYjB3AZTedDFnS"
#endif
    }

    var segmentAnalyticsFlushAt: Int {
#if DEBUG || QA
        return 1
#else
        return 20
#endif
    }

    var segmentTrackApplicationLifecycleEvents: Bool {
        true
    }

    var segmentProxyURLHost: String {
        "www.amboss.com"
    }

    var segmentProxyURLPath: String {
        switch appVariant {
        case .wissen: return "/de/api/sprx/v1/batch"
        case .knowledge: return "/us/api/sprx/v1/batch"
        }
    }

    var adjustAppToken: String {
        switch appVariant {
        case .wissen: return "lhadpobc7s3k"
        case .knowledge: return "ggyxjbtdwnwg"
        }
    }

    // MARK: - Braze
    var brazeAPIKey: String {
#if DEBUG || QA
        return "13ae8232-8503-412d-a973-a3a4648fa7a5"
#else
        return "41bc21b8-4dd6-43a5-b553-7050807f96a3"
#endif
    }
    var brazeEndpoint: String {
        "sdk.fra-02.braze.eu"
    }
}
