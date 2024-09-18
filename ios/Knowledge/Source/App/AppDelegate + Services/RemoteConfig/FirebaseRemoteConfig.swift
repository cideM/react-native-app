//
//  FirebaseRemoteConfig.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 29.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import FirebaseRemoteConfig
import Domain
import Localization

final class FirebaseRemoteConfig: RemoteConfigType {

    private let config: RemoteConfig
    private let appConfig: Configuration

    var requestTimeout: NSNumber {
        let timeout = config["request_timeout"].numberValue
        if timeout == 0 {
            // If the timeout is zero all requests fail immediately.
            return 1
        }
        return timeout
    }

    var searchAdConfig: SearchAdConfig {
        do {
            let data = config["ios_pharma_search_ad_config"].dataValue
            return try JSONDecoder().decode(SearchAdConfig.self, from: data)
        } catch {
            return SearchAdConfig()
        }
    }

    var areMonographsEnabled: Bool {
        config["ios_monographs_enabled"].boolValue
    }

    var pharmaDosageTooltipV1Enabled: Bool {
        #if DEBUG
        return true
        #else
        return config["ios_pharma_dosage_tooltip_v1_enabled"].boolValue
        #endif
    }

    var pharmaDosageNGDENavigationEnabled: Bool {
        #if DEBUG
        return true
        #else
        return config["ios_pharma_dosage_ngde_navigation_enabled"].boolValue
        #endif
    }

    var brazeEnabled: Bool {
        #if DEBUG
        return true
        #else
        config["ios_braze_integration_enabled"].boolValue
        #endif
    }

    var contentCardsEnabled: Bool {
        #if DEBUG
        return true
        #else
        config["ios_content_cards_enabled"].boolValue
        #endif
    }

    var iap5DayTrialRemoved: Bool {
        #if DEBUG
        return false
        #else
        config["ios_remove_iap_5day_trial"].boolValue
        #endif
    }

    var medicationLinkReplacements: [(snippet: SnippetIdentifier, monograph: MonographIdentifier)]? {
        switch appConfig.appVariant {
        case .wissen:
            return nil
        case .knowledge:
            let key = "ios_us_clinician_medication_link_replacements"
            guard let strings = (config[key].jsonValue as? [[String]]) else { return nil }
            let replacements: [(snippet: SnippetIdentifier, monograph: MonographIdentifier)] = strings.compactMap { item in
                guard
                    let snippet = item.first,
                    let monograph = item.last,
                    let snippetID = SnippetIdentifier(snippet),
                    let monographID = MonographIdentifier(monograph)
                else { return nil }
                return (snippet: snippetID, monograph: monographID)
            }
            guard !replacements.isEmpty else { return nil }
            return replacements
        }
    }

    var termsReAcceptanceEnabled: Bool {
        config["ios_tc_reacceptance_enabled"].boolValue
    }

    var dashboardCMELinkEnabled: Bool {
        config["ios_dashboard_cme_link_enabled"].boolValue
    }

    init(config: RemoteConfig = RemoteConfig.remoteConfig(), appConfig: Configuration = AppConfiguration.shared) {
        self.config = config
        self.appConfig = appConfig

        setDefaults()

        // As mentioned in Firebase documentation, we should during development, it's recommended to set a relatively low minimum fetch interval.
        // https://firebase.google.com/docs/remote-config/use-config-ios
        #if DEBUG || QA
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        self.config.configSettings = settings
        #endif
    }

    private func setDefaults() {
        let defaults: [String: NSObject] = [
            "ios_rote_hand_age_threshold_days": NSNumber(value: 186),
            "request_timeout": NSNumber(value: 2),
            "ios_monographs_enabled": NSNumber(value: false),
            "ios_pharma_dosage_tooltip_v1_enabled": NSNumber(value: false),
            "ios_braze_integration_enabled": NSNumber(value: false),
            "ios_remove_iap_5day_trial": NSNumber(value: false),
            "ios_tc_reacceptance_enabled": NSNumber(value: false),
            "ios_dashboard_cme_link_enabled": NSNumber(value: false)
        ]
        self.config.setDefaults(defaults)
    }

    func fetch(completion: @escaping (Result<Void, RemoteConfigSynchError>) -> Void) {
        config.fetch { result, error in
            switch result {
            case .success:
                self.config.activate { _, error in
                    if error != nil {
                        completion(.failure(RemoteConfigSynchError.activationFailed(error)))
                    } else {
                        completion(.success(()))
                    }
                }
            case .failure:
                completion(.failure(RemoteConfigSynchError.fetchFailed(error)))
            case .noFetchYet:
                completion(.failure(RemoteConfigSynchError.noFetchYet(error)))
            case .throttled:
                completion(.failure(RemoteConfigSynchError.fetchThrottled(error)))
            @unknown default:
                completion(.failure(RemoteConfigSynchError.unknownError(error)))
            }
        }
    }

}

extension DiscoverAmbossConfig {
    static var deDefault: DiscoverAmbossConfig {
        var drugReferences: [Item] {
            let item1Url = URL(string: "https://next.amboss.com/de/pharma/1916/1059659?q=Ramipril")! // swiftlint:disable:this force_unwrapping
            let item1 = Item(title: "Ramipril", deepLink: Deeplink(url: item1Url), url: item1Url)

            let item2Url = URL(string: "https://next.amboss.com/de/pharma/678/1037192?q=apixaban")! // swiftlint:disable:this force_unwrapping
            let item2 = Item(title: "Apixaban", deepLink: Deeplink(url: item2Url), url: item2Url)

            return [item1, item2]
        }

        var articleReferences: [Item] {
            let item1Url = URL(string: "https://next.amboss.com/de/article/Xh09cf?q=arterielle%20hypertonie#Z3d73ccc1b405184a8d3087bd8b727eb4")! // swiftlint:disable:this force_unwrapping
            let item1 = Item(title: "Arterielle Hypertonie", deepLink: Deeplink(url: item1Url), url: item1Url)

            let item2Url = URL(string: "https://next.amboss.com/de/article/pl0LBT?q=EKG#Z1d00f1e5d20ccb9473d097ddbcaf722e")! // swiftlint:disable:this force_unwrapping
            let item2 = Item(title: "EKG", deepLink: Deeplink(url: item2Url), url: item2Url)

            return [item1, item2]
        }

        let calculatorsUrl = URL(string: "https://next.amboss.com/de/search?q=Rechner%3A&v=media")! // swiftlint:disable:this force_unwrapping
        let calculators = Item(title: L10n.Dashboard.Sections.DiscoverAmboss.Sections.ClinicalTools.Calculators.title, deepLink: Deeplink(url: calculatorsUrl), url: calculatorsUrl)

        let algorithmsUrl = URL(string: "https://next.amboss.com/de/search?q=Algorithmus%3A&v=media")! // swiftlint:disable:this force_unwrapping
        let algorithms = Item(title: L10n.Dashboard.Sections.DiscoverAmboss.Sections.ClinicalTools.Algorithms.title, deepLink: Deeplink(url: algorithmsUrl), url: algorithmsUrl)

        return DiscoverAmbossConfig(drugReferences: drugReferences,
                                    articleReferences: articleReferences,
                                    calculators: calculators,
                                    algorithms: algorithms)
    }

    static var usDefault: DiscoverAmbossConfig {
        var drugReferences: [Item] {
            let item1Url = URL(string: "https://next.amboss.com/us/pharma/lisinopril?q=lisinopril")! // swiftlint:disable:this force_unwrapping
            let item1 = Item(title: "Lisinopril", deepLink: Deeplink(url: item1Url), url: item1Url)

            let item2Url = URL(string: "https://next.amboss.com/us/pharma/metoprolol?q=metoprolol")! // swiftlint:disable:this force_unwrapping
            let item2 = Item(title: "Metoprolol", deepLink: Deeplink(url: item2Url), url: item2Url)

            return [item1, item2]
        }

        var articleReferences: [Item] {
            let item1Url = URL(string: "https://next.amboss.com/us/article/GS0Baf?q=atrial%20fibrillation#Z1c935e9d1930e026a94771ff297965bb")! // swiftlint:disable:this force_unwrapping
            let item1 = Item(title: "Atrial fibrillation", deepLink: Deeplink(url: item1Url), url: item1Url)

            let item2Url = URL(string: "https://next.amboss.com/us/article/mh0Vef?q=pneumonia#Z36f83311c3582932defdae7a73e5730b")! // swiftlint:disable:this force_unwrapping
            let item2 = Item(title: "Pneumonia", deepLink: Deeplink(url: item2Url), url: item2Url)

            return [item1, item2]
        }

        let calculatorsUrl = URL(string: "https://next.amboss.com/us/search?q=Calculators%3A&v=media")! // swiftlint:disable:this force_unwrapping
        let calculators = Item(title: L10n.Dashboard.Sections.DiscoverAmboss.Sections.ClinicalTools.Calculators.title, deepLink: Deeplink(url: calculatorsUrl), url: calculatorsUrl)

        let algorithmsUrl = URL(string: "https://next.amboss.com/us/search?q=Algorithms%3A&v=media")! // swiftlint:disable:this force_unwrapping
        let algorithms = Item(title: L10n.Dashboard.Sections.DiscoverAmboss.Sections.ClinicalTools.Algorithms.title, deepLink: Deeplink(url: algorithmsUrl), url: algorithmsUrl)

        return DiscoverAmbossConfig(drugReferences: drugReferences,
                                    articleReferences: articleReferences,
                                    calculators: calculators,
                                    algorithms: algorithms)
    }
}
