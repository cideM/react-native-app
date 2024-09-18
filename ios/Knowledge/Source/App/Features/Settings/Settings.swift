//
//  SettingsViewData.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 20.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

enum Settings { }

extension Settings {
    struct Section {
        let title: String
        var items: [Item]
        let footer: String
    }
}

extension Settings {
    struct Item {
        let title: String
        let subtitle: String
        let hasChevron: Bool
        let subtitleWarning: Bool
        let itemType: ItemType
    }
}

extension Settings {
    enum ItemType: Equatable {
        case accountSettings
        case shop
        case userstage
        case studyobjective
        case redeemCode(code: String? = nil)
        case offlineaccess
        case extensions
        case library
        case appearance
        case quickstart
        case supportus
        case qbank
        case about

        // Associated value in "redeemCode" need manual "equatable" implementation ...
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.accountSettings, .accountSettings): return true
            case (.shop, .shop): return true
            case (.userstage, .userstage): return true
            case (.studyobjective, .studyobjective): return true
            case (.redeemCode(let lhsCode), .redeemCode(let rhsCode)): return lhsCode == rhsCode
            case (.offlineaccess, .offlineaccess): return true
            case (.extensions, .extensions): return true
            case (.library, .library): return true
            case (.appearance, .appearance): return true
            case (.quickstart, .quickstart): return true
            case (.supportus, .supportus): return true
            case (.qbank, .qbank): return true
            case (.about, .about): return true
            default: return false
            }
        }
    }
}
