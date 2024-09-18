//
//  PopoverViewController.swift
//  Knowledge
//
//  Created by CSH on 13.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import WebKit

/// @mockable
protocol PopoverViewType: AnyObject {
    var preferredContentSize: CGSize { get set }

    func setIsLoading(_ isLoading: Bool)
    func load(document: HtmlDocument)
}

final class PopoverViewController: UIViewController, PopoverViewType {
    private let presenter: PopoverPresenterType

    private lazy var bridge = WebViewBridge(delegate: presenter)
    private lazy var webView: WKWebView = {
        let configuration = bridge.webViewConfiguration
        configuration.setURLSchemeHandler(libraryArchiveSchemeHandler, forURLScheme: LibraryArchiveSchemeHandler.scheme) // Loads js from archive
        configuration.setURLSchemeHandler(CommonBundleSchemeHandler(), forURLScheme: CommonBundleSchemeHandler.scheme)  // Loads fonts from bundle
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        return webView
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = UIActivityIndicatorView.Style.medium
        view.hidesWhenStopped = true
        return view
    }()

    private let libraryArchiveSchemeHandler: LibraryArchiveSchemeHandler

    init(presenter: PopoverPresenterType, handler: LibraryArchiveSchemeHandler) {
        self.presenter = presenter
        self.libraryArchiveSchemeHandler = handler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        presenter.view = self
    }

    func setIsLoading(_ isLoading: Bool) {
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }

    func load(document: HtmlDocument) {
        bridge.resetState()
        webView.loadHTMLString(document.asHtml, baseURL: LibraryArchiveSchemeHandler.baseUrl())
    }

    private func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.constrainEdges(to: view)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        presenter.boundsChanged()
    }
}

extension PopoverViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated, ["http", "https"].contains(url.scheme) {
            presenter.openURL(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
        presenter.didFinishUrlLoading()
    }
}
