//
//  Video.swift
//  Interfaces
//
//  Created by Silvio Bulla on 25.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public enum Video {
    // sourcery: fixture:default=".youtube("kfVsfOSbJY0")"
    case youtube(String)
    // sourcery: fixture:default=".vimeo("342949798")"
    case vimeo(String)

    public var url: URL {
        switch self {
        case .youtube(let id): return URL(string: "http://www.youtube.com/watch?v=\(id)")! // swiftlint:disable:this force_unwrapping
        case .vimeo(let id): return URL(string: "http://player.vimeo.com/video/\(id)")! // swiftlint:disable:this force_unwrapping
        }
    }
}
