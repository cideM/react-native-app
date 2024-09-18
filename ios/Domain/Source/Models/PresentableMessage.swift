//
//  PresentableMessage.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 30.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import UIKit

public struct PresentableMessage: PresentableMessageType {
    public var title: String
    public var body: String
    public var logLevel: MonitorLevel
    public var debugDescription: String {
        "\(self)"
    }
    public var image: UIImage?

    public init(title: String, description: String, logLevel: MonitorLevel, image: UIImage? = nil) {
        self.title = title
        self.body = description
        self.logLevel = logLevel
        self.image = image
    }
}
