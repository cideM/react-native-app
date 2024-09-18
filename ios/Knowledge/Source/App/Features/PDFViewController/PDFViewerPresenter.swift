//
//  PDFViewerPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import PDFKit
import Localization

protocol PDFViewerPresenterType: AnyObject {
    var view: PDFViewerViewType? { get set }
    func shareDocument()
}

class PDFViewerPresenter: PDFViewerPresenterType {

    private let coordinator: PDFViewerCoordinatorType
    private let mediaClient: MediaClient
    @Inject private var monitor: Monitoring

    private let url: URL
    private let title: String
    private let temporaryLocalFileURL: URL

    weak var view: PDFViewerViewType? {
        didSet {
            downloadDocument()
            view?.set(title: title)
        }
    }

    init(coordinator: PDFViewerCoordinatorType, url: URL, title: String, mediaClient: MediaClient = resolve(), temporaryLocalFileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)) {
        self.coordinator = coordinator
        self.url = url
        self.title = title
        self.mediaClient = mediaClient
        self.temporaryLocalFileURL = temporaryLocalFileURL
    }

    deinit {
        try? FileManager.default.removeItem(at: temporaryLocalFileURL)
    }

    private func downloadDocument() {
        view?.setIsLoading(true)
        mediaClient.downloadData(at: url) { [weak self] result in
            guard let self = self else { return }
            self.view?.setIsLoading(false)

            switch result {
            case .success(let data):
                do {
                    try data.write(to: self.temporaryLocalFileURL)
                    if let document = PDFDocument(data: data) {
                        self.view?.showDocument(document)
                    } else {
                        self.showError(PDFViewerError.pdfDocumentCouldNotBeConstructed)
                    }
                } catch {
                    self.monitor.debug("Failed to write PDF data.", context: .system)
                    self.showError(PDFViewerError.dataCouldNotBeWritten)
                }
            case .failure(let error):
                self.showError(error)
            }
        }
    }

    private func showError(_ error: PresentableMessageType) {
        let action = MessageAction(title: L10n.Generic.retry, style: .normal) { [weak self] in
            self?.downloadDocument()
            return true
        }
        view?.showError(error, actions: [action])
    }

    func shareDocument() {
        coordinator.shareDocument(temporaryLocalFileURL, with: "\(title).pdf")
    }
}
