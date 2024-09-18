//
//  DeepLinkService.swift
//  Knowledge
//
//  Created by Vedran Burojevic on 07/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol DeepLinkServiceType: AnyObject {
    var delegate: DeepLinkServiceDelegate? { get set }
    var deferDeepLinks: Bool { get set }
    func handleDeepLink(_ deepLink: Deeplink)
    @discardableResult func handleWebpageURL(_ webpageURL: URL) -> Bool
}

/// @mockable
protocol DeepLinkServiceDelegate: AnyObject {
    func didReceiveDeepLink(_ deepLink: Deeplink)
}

final class DeepLinkService: DeepLinkServiceType {

    // MARK: - Public properties -

    weak var delegate: DeepLinkServiceDelegate?

    var deferDeepLinks = true {
        didSet {
            if let deferredDeepLink = deferredDeepLink, !deferDeepLinks {
                delegate?.didReceiveDeepLink(deferredDeepLink)
                self.deferredDeepLink = nil
            }
        }
    }

    // MARK: - Private properties -

    private var deferredDeepLink: Deeplink?
    @LazyInject private var monitor: Monitoring

    private static let pocketGuidesFeatureFlag = "can_see_pocket_guides"

    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let featureFlagRepository: FeatureFlagRepositoryType

    init(remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         featureFlagRepository: FeatureFlagRepositoryType = resolve()) {
        self.featureFlagRepository = featureFlagRepository
        self.remoteConfigRepository = remoteConfigRepository
    }
}

extension DeepLinkService {
    func handleDeepLink(_ deepLink: Deeplink) {

        if deferDeepLinks {
            deferredDeepLink = deepLink
        } else {
            delegate?.didReceiveDeepLink(deepLink)
        }
    }

    func handleWebpageURL(_ webpageURL: URL) -> Bool {
        var deepLink = Deeplink(url: webpageURL)

        // Recast a "monograph" deeplink to an "unsupported" one in case monographs are disabled
        // This way the user can still open a webpage in the app instead of stranding nowhere
        switch deepLink {
        case .login, .learningCard, .pharmaCard, .search, .uncommitedSearch, .unsupported, .settings, .productKey:
            break
        case .pocketGuides:
            if self.featureFlagRepository.featureFlags.contains(Self.pocketGuidesFeatureFlag) {
                // Only show pocket guides for users who have the flag enabled 
                deepLink = Deeplink.unsupported(webpageURL)
            }
        case .monograph:
            if !remoteConfigRepository.areMonographsEnabled {
                deepLink = Deeplink.unsupported(webpageURL)
            }
        }
        if case let .unsupported(url) = deepLink {
            monitor.error(DeeplinkError.unsupportedUrl(url), context: .navigation)
        }

        if deferDeepLinks {
            deferredDeepLink = deepLink
        } else {
            delegate?.didReceiveDeepLink(deepLink)
        }

        return true
    }
}

enum DeeplinkError: Error {
    /// The app was opened with an unsupported URL
    case unsupportedUrl(URL)
}
