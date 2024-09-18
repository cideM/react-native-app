//
//  MiniMapViewItem.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 03.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct MiniMapViewItem {
    let miniMapNode: MinimapNodeMeta
    let itemType: ItemType
}

enum ItemType {
    case parent
    case child
}
