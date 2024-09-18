//
//  PDFViewerViewController.swift
//  Common
//
//  Created by Silvio Bulla on 30.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import PDFKit
import UIKit

/// @mockable
protocol PDFViewerViewType: AnyObject {
    func setIsLoading(_ isLoading: Bool)
    func showError(_ error: PresentableMessageType, actions: [MessageAction])
    func showDocument(_ document: PDFDocument)
    func set(title: String)
}

class PDFViewerViewController: UIViewController, PDFViewerViewType {
    private let presenter: PDFViewerPresenterType

    init(presenter: PDFViewerPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    private lazy var errorPresenter = SubviewMessagePresenter(rootView: self.view)
    private lazy var shareButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }()

    private let pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        view.addSubview(pdfView)
        pdfView.constrainEdges(to: view)

        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navigationItem.rightBarButtonItem = shareButton
    }

    func set(title: String) {
        self.title = title
    }

    func setIsLoading(_ isLoading: Bool) {
        activityIndicatorView.setAnimating(isLoading)
    }

    func showError(_ error: PresentableMessageType, actions: [MessageAction]) {
        errorPresenter.present(error, actions: actions)
    }

    func showDocument(_ document: PDFDocument) {
        pdfView.document = document
    }

    @objc func share() {
        presenter.shareDocument()
    }
}
