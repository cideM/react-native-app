//
//  MediaSearchViewItem.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 29.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

struct MediaSearchViewItem {
    let mediaId: String
    let title: String
    let externalAdditionType: ExternalAddition.Types?
    let category: MediaSearchItem.Category
    let typeName: String
    let targetUuid: String
    let tapHandler: (MediaSearchViewItem) -> Void
    let loadImage: (@escaping (Result<UIImage, Error>) -> Void) -> Void

    init(mediaId: String,
         title: String,
         url: URL,
         externalAdditionType: ExternalAddition.Types?,
         category: MediaSearchItem.Category,
         typeName: String,
         targetUuid: String,
         tapHandler: @escaping (MediaSearchViewItem) -> Void,
         imageLoader: @escaping (_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void) {

        self.mediaId = mediaId
        self.title = title
        self.externalAdditionType = externalAdditionType
        self.category = category
        self.typeName = typeName
        self.targetUuid = targetUuid
        self.tapHandler = tapHandler

        loadImage = { completion in
            imageLoader(url, completion)
        }
    }
}
