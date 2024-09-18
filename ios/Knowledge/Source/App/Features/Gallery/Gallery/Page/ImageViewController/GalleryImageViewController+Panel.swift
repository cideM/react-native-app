//
//  GalleryImageViewController+Panel.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import Common
import UIKit
import DesignSystem

extension GalleryImageViewController {

    func panelMinHeight() -> CGFloat {
        // WORKAROUND:
        // view.safeAreaInsets.bottom always returns "0"
        // This is likely happening because this viewcontrollers view
        // is not a direct subview of its parent viewcontrollers view
        // Fetching the insets from the windows works though.
        // We do this in order to move the panel above the "home indicator strip" when required ...
        let bottomInset = UIApplication.activeKeyWindow?.safeAreaInsets.bottom ?? 0
        return bottomInset + contentViewController.titleHeight()
    }

    func panelExpandedHeight() -> CGFloat {
        var bottomInset = UIApplication.activeKeyWindow?.safeAreaInsets.bottom ?? 0
        if bottomInset == 0 { bottomInset = 8.0 }

        // The panel changes its width when growing hence we pass in the "grown width" here already
        // so that we get the proper content height for the expanded state already ...
        let height = min(view.bounds.height / 2.0, contentViewController.titleAndContentHeight(for: expandedPanelWidth)) + bottomInset
        return height
    }

    func makePanelContentViewController() -> ImageDescriptionViewController {
        let viewController = ImageDescriptionViewController()

        let image = presenter.image
        viewController.setTitle(image.title ?? "")
        viewController.setDescription(image.description)
        viewController.setCopyrightDescription(image.copyright)
        viewController.scrollViewDelegate = self
        viewController.chevronTapCallback = { [weak self] in
            self?.togglePanel()
        }
        viewController.linkTapCallback = { [weak self] url in
            self?.presenter.openURL(url)
        }

        return viewController
    }

    func makePanel(with contentViewController: ImageDescriptionViewController) -> Panel? {
        var configuration = Panel.Configuration.default
        configuration.appearance.resizeHandle = .hidden

        let isEmpty = presenter.image.description.isEmpty && presenter.image.copyright.isEmpty
        configuration.appearance.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        configuration.appearance.shadowOpacity = isEmpty ? 0 : 0.15

        let panel = Panel(configuration: configuration)
        panel.configuration.positionLogic = [.bottom: .ignoreSafeArea]
        panel.contentViewController = contentViewController

        panel.sizeDelegate = self
        panel.resizeDelegate = self

        // Enable full height panels for content that would cover most of the screen
        // Ex: DE: Chondrale Ossifikation mit verkalkter Knorpelmatrix -> image results, first image
        var supportedModes: Set<Aiolos.Panel.Configuration.Mode> = isEmpty ? [.compact] : [.compact, .expanded]
        if contentViewController.contentHeight(for: expandedPanelWidth) > view.bounds.height * 0.75 {
            supportedModes.insert(.fullHeight)
        }
        panel.configuration.supportedModes = supportedModes

        panel.view.isUserInteractionEnabled = !isEmpty

        return panel
    }
}
