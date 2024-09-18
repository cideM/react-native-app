//
//  DosagePopoverViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 12.04.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import WebKit
import Localization
import DesignSystem

/// @mockable
protocol DosagePopoverViewType: AnyObject {
    var preferredContentSize: CGSize { get set }
    func setContent(_ viewData: DosagePopoverViewData)
}

final class DosagePopoverViewController: UIViewController, DosagePopoverViewType {
    private var presenter: DosagePopoverPresenterType

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private var separator: UIView?
    private var linkView: UIView?

    private lazy var bridge = WebViewBridge(delegate: presenter)
    private lazy var webView: WKWebView = {
        let configuration = bridge.webViewConfiguration
        configuration.setURLSchemeHandler(libraryArchiveSchemeHandler, forURLScheme: LibraryArchiveSchemeHandler.scheme) // Loads js from archive
        configuration.setURLSchemeHandler(CommonBundleSchemeHandler(), forURLScheme: CommonBundleSchemeHandler.scheme)  // Loads fonts from bundle
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.alpha = 0 // Remove whtie flicker on appear ...
        return webView
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.style = .medium
        view.setAnimating(true)
        return view
    }()

    private let libraryArchiveSchemeHandler: LibraryArchiveSchemeHandler
    private let contentSizeCalculator = HTMLContentSizeCalculator()
    private var stackViewObservation: NSKeyValueObservation?
    private var document: HtmlDocument?
    private var minHeight: CGFloat = 0
    private let seperatorHeight: CGFloat = 16

    // Height is just enough to look good with the spinner
    // preferredContentSize will be updated once the page has loaded ...
    private let defaultHeight: CGFloat = 60

    required init(presenter: DosagePopoverPresenter, handler: LibraryArchiveSchemeHandler) {
        self.libraryArchiveSchemeHandler = handler
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.Dosage.Popover.title

        preferredContentSize = .init(width: AppConfiguration.shared.popoverWidth, height: defaultHeight)
        view.backgroundColor = .clear

        view.addSubview(stackView)

        stackView.addArrangedSubview(webView) // -> webview is inside stackview cause buttons will be added below later

        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        presenter.view = self
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePreferredContentSize(for: document)
    }

    func setContent(_ viewData: DosagePopoverViewData) {
        webView.alpha = 0

        let document = HtmlDocument.popoverDocument(viewData.html)
        self.document = document

        if let title = viewData.ambossSubstanceName,
           let ambossSubstanceLink = viewData.ambossSubstanceLink {
            addLink(title: title, ambossSubstanceLink: ambossSubstanceLink)
        }

        updatePreferredContentSize(for: document)
    }

    private func addLink(title: String, ambossSubstanceLink: AmbossSubstanceLink) {
        minHeight = PopoverLinkView.defaultHeight + seperatorHeight  // height of button and seperators
        addLinkViewSeparator()
        addPopoverLinkView(with: title, ambossSubstanceLink: ambossSubstanceLink)
    }

    private func addLinkViewSeparator() {
        let separator = UIView()
        let container = UIView()

        separator.backgroundColor = .separator
        container.backgroundColor = .clear
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(container)
        container.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.topAnchor.constraint(equalTo: container.topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            container.heightAnchor.constraint(equalToConstant: seperatorHeight)
        ])
        separator.alpha = 0.0
        self.separator = separator
    }

    private func addPopoverLinkView(with title: String, ambossSubstanceLink: AmbossSubstanceLink) {
        let button = createPopoverLinkView(with: title, ambossSubstanceLink: ambossSubstanceLink)
        button.heightAnchor.constraint(equalToConstant: PopoverLinkView.defaultHeight).isActive = true
        stackView.addArrangedSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.0
        self.linkView = button
    }

    private func createPopoverLinkView(with title: String, ambossSubstanceLink: AmbossSubstanceLink) -> UIView {
        let button = PopoverLinkView(title: title,
                                     image: Asset.Icon.pillIcon.image) { [weak self] in
            self?.presenter.didTap(ambossSubstanceLink: ambossSubstanceLink)
        }
        return button
    }
}

private extension DosagePopoverViewController {

    func updatePreferredContentSize(for document: HtmlDocument?) {
        guard let document = document else {
            return
        }

        let width = AppConfiguration.shared.popoverWidth
        contentSizeCalculator.calculateSize(for: document, width: width) { [weak self] documentSize in
            UIView.animate(withDuration: 0.25, animations: {
                self?.activityIndicatorView.alpha = 0
            }, completion: {  _ in
                guard let self = self else { return }
                self.webView.loadHTMLString(document.asHtml, baseURL: LibraryArchiveSchemeHandler.baseUrl())
                UIView.animate(withDuration: 0.5) {
                    self.webView.alpha = 1.0
                    self.separator?.alpha = 1.0
                    self.linkView?.alpha = 1.0
                }
                let totalHeight = documentSize.height + self.minHeight
                self.preferredContentSize = .init(width: width, height: totalHeight)
                self.webView.scrollView.isScrollEnabled = documentSize.height > self.webView.bounds.height
            })
        }
    }
}
