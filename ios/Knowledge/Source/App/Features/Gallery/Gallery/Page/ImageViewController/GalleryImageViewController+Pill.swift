//
//  GalleryImageViewController+Pill.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 21.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import UIKit

extension GalleryImageViewController {

    func addPill(constraintTo panel: Panel) {

        let pill = PillViewController()
        addChild(pill)
        view.addSubview(pill.view)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: pill.view.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: pill.view.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: pill.view.topAnchor),
            pill.view.bottomAnchor.constraint(equalTo: panel.view.topAnchor)
        ])

        pill.didMove(toParent: self)
        self.pill = pill
    }
}
