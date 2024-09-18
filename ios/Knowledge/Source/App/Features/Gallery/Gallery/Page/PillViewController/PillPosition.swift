//
//  PillPosition.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

extension PillContainerView {

    enum PillPosition: Int, Codable {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight

        init(isMaxX: Bool, isMaxY: Bool) {
            switch (isMaxX, isMaxY) {
            case (false, false): self = .bottomRight
            case (true, false): self = .bottomLeft
            case (true, true): self = .topLeft
            case (false, true ): self = .topRight
            }
        }
    }
}
