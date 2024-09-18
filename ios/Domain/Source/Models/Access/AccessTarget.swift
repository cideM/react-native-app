//
//  AccessTarget.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 26.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

public typealias AccessTarget = Identifier<Void, String>

public enum AccessTargets {
    public static let learningCard: AccessTarget = .init(value: "learning_card")
    public static let libraryArchive: AccessTarget = .init(value: "library_archive")
}
