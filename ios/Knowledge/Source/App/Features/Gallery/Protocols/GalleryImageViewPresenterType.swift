//
//  GalleryImageViewPresenterType.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 08.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol GalleryImageViewPresenterType: AnyObject {
    var view: GalleryImageViewType? { get set }
    var image: ImageResourceType { get }
    var delegate: GalleryImageViewPresenterDelegate? { get set }

    func setFullscreen(_ value: Bool)
    func toggleImageOverlay()
    func openURL(_ url: URL)

    func trackImageDescriptionPresented()
    func trackImageDescriptionDismissed()

    func viewWillAppear()
    func navigate(to externalAddition: ExternalAddition)
    func viewDidDisappear()

    func updateDraggingState(isDragging: Bool)
}

protocol GalleryImageViewPresenterDelegate: AnyObject {
    func didUpdateDraggingState(isDragging: Bool)
    func didUpdateFullscreen(_ value: Bool)
}
