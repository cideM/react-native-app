//
//  LibraryUpdaterType.swift
//  Knowledge
//
//  Created by CSH on 20.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

protocol LibraryUpdaterType: AnyObject {
    var isBackgroundUpdatesEnabled: Bool { get set }
    var state: LibraryUpdaterState { get }
    func initiateUpdate(isUserTriggered: Bool)
}
