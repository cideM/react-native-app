//
//  PDFViewerError+PresentableMessage.swift
//  Knowledge
//
//  Created by Silvio Bulla on 14.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

extension PDFViewerError: PresentableMessageType {
    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        switch  self {
        case .pdfDocumentCouldNotBeConstructed, .dataCouldNotBeWritten: return L10n.Error.Generic.title
        }
    }

    public var body: String {
        switch  self {
        case .pdfDocumentCouldNotBeConstructed, .dataCouldNotBeWritten: return L10n.Error.Generic.message
        }
    }

    public var logLevel: MonitorLevel {
        switch  self {
        case .pdfDocumentCouldNotBeConstructed, .dataCouldNotBeWritten: return .warning
        }
    }
}
