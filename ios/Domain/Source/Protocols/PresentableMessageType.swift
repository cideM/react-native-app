//
//  PresentableMessageType.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/11/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// Any error that is going to be presented in any means should implement this protocol.
public protocol PresentableMessageType: Error {
    /// The debugDescription should never be displayed to the user. It can be used as a developer
    /// message, e.g. to show in a logfile.
    var debugDescription: String { get }
    var title: String { get }
    var body: String { get }
    var logLevel: MonitorLevel { get }

    var image: UIImage? { get }
}

public extension PresentableMessageType {
    var image: UIImage? {
        nil
    }
}
