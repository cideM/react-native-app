//
//  StoryboardIdentifyable.swift
//  Common
//
//  Created by Silvio Bulla on 09.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public protocol StoryboardIdentifiable: AnyObject {

    /// A storyboard identifier from which an instance can be instantiated.
    static var storyboardIdentifier: String { get }

}

public extension StoryboardIdentifiable {

    /// The default `storyboardIdentifier` is the type name.
    static var storyboardIdentifier: String {
        String(describing: self)
    }

}
