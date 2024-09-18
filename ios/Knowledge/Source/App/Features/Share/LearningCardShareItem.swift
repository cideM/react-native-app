//
//  LearningCardShareItem.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 09.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class LearningCardShareItem: NSObject, UIActivityItemSource {

    private let title: String
    private let message: String
    private let remoteURL: URL

    // sourcery: fixture:
    init(title: String, message: String, remoteURL: URL ) {
        self.title = title
        self.message = message
        self.remoteURL = remoteURL
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        title
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        remoteURL
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let activityType = activityType else { return remoteURL }
        switch activityType {
        case .message, .mail: return message
        default: return remoteURL
        }
    }
}
