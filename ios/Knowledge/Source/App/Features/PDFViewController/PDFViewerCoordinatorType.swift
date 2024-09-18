//
//  PDFViewerCoordinatorType.swift
//  Knowledge
//
//  Created by Silvio Bulla on 09.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Foundation
/// @mockable
protocol PDFViewerCoordinatorType: Coordinator {
    func shareDocument(_ url: URL, with filename: String)
}
