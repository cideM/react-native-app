//
//  PDFViewerError.swift
//  Interfaces
//
//  Created by Silvio Bulla on 14.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public enum PDFViewerError: Error {
    case pdfDocumentCouldNotBeConstructed
    case dataCouldNotBeWritten
}
