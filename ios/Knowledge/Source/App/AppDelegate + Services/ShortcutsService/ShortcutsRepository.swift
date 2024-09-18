//
//  ShortcutsRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 20.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

/// @mockable
protocol ShortcutsRepositoryType: AnyObject {
    func increaseUsageCount(for ambossShortcut: AmbossShortcut)
    func shouldOfferAddingVoiceShortcut(for ambossShortcut: AmbossShortcut) -> Bool
    func addingVoiceShortcutWasOffered(for ambossShortcut: AmbossShortcut)
}

final class ShortcutsRepository: ShortcutsRepositoryType {
    private let storage: Storage

    private let minSearchUsageCount = 4
    private var searchUsageCount: Int {
        get {
            storage.get(for: .searchUsageCount) ?? 0
        }
        set {
            storage.store(newValue, for: .searchUsageCount)
        }
    }
    private var addingVoiceShortcutForSearchWasOffered: Bool {
        get {
            storage.get(for: .addingVoiceShortcutForSearchWasOffered) ?? false
        }
        set {
            storage.store(newValue, for: .addingVoiceShortcutForSearchWasOffered)
        }
    }

    init(storage: Storage = resolve(tag: .default)) {
        self.storage = storage
    }

    func increaseUsageCount(for ambossShortcut: AmbossShortcut) {
        switch ambossShortcut {
        case .search: searchUsageCount += 1
        }
    }

    func shouldOfferAddingVoiceShortcut(for ambossShortcut: AmbossShortcut) -> Bool {
        switch ambossShortcut {
        case .search: return !addingVoiceShortcutForSearchWasOffered && searchUsageCount > minSearchUsageCount
        }
    }

    func addingVoiceShortcutWasOffered(for ambossShortcut: AmbossShortcut) {
        switch ambossShortcut {
        case .search: addingVoiceShortcutForSearchWasOffered = true
        }
    }
}
