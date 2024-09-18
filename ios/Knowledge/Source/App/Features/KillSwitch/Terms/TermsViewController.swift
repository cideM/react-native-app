//
//  TermsViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.04.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import WebKit
import DesignSystem
import Localization

protocol TermsViewType: AnyObject {
    func set(html: HtmlDocument)
}

class TermsViewController: UIViewController, TermsViewType {

    // MARK: - Init

    init(presenter: TermsPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Template functions

    override func viewDidLoad() {
        super.viewDidLoad()

        dialog.set(callToAction: L10n.Terms.AcceptButton.title) { [weak self] in
            self?.presenter.acceptTerms()
        }

        dialog.set(urlCallback: { [weak self] url in
            self?.presenter.openExternally(url: url)
        })

        view.addSubview(dialog)
        dialog.pin(to: view)
        presenter.view = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    // MARK: - TermsViewType

    func set(html: HtmlDocument) {
        let width = dialog.availableContentWidth()
        self.calculator.calculateSize(for: html, width: width) { [weak self] size in
            guard let self else { return }
            let height = size.height
            dialog.set(html: html.asHtml, contentHeight: height)
        }
    }

    // MARK: - Private vars

    private var presenter: TermsPresenterType

    let config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(CommonBundleSchemeHandler(), forURLScheme: CommonBundleSchemeHandler.scheme) // Loads fonts from bundle
        return config
    }()

    // These need the "config", hence lazy ...
    private lazy var calculator = HTMLContentSizeCalculator(config: config)
    private lazy var dialog: ModalWebViewDialog = {
        let view = ModalWebViewDialog(config: config)
        return view
    }()
}
