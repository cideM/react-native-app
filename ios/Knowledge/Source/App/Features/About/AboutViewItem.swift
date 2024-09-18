//
//  AboutViewItem.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Localization

public struct AboutViewItem {
    let type: ItemType
    var title: String {
        switch type {
        case .legal: L10n.AboutSettings.LegalNotice.title
        case .privacy: L10n.AboutSettings.Privacy.title
        case .consentManagement: L10n.AboutSettings.ConsentManagement.title
        case .libraries: L10n.AboutSettings.Libraries.title
        case .terms: L10n.Settings.More.Terms.title
        }
    }
}

extension AboutViewItem {
    enum ItemType {
        case legal
        case privacy
        case consentManagement
        case libraries
        case terms
    }
}
