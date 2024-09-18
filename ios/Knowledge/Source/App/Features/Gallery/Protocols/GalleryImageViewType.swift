//
//  GalleryImageViewType.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 08.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation
import UIKit

/// @mockable
protocol GalleryImageViewType: AnyObject {
    func setIsLoading(_ isLoading: Bool)
    func showError(_ error: PresentableMessageType, actions: [MessageAction])
    func setImage(_ image: UIImage)
    func setExternalAdditions(_ features: [ExternalAddition], hasOverlay: Bool)
}
