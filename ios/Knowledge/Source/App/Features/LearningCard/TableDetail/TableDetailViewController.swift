//
//  TableDetailViewController.swift
//  Knowledge
//
//  Created by CSH on 04.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import WebKit
import Localization

/// @mockable
protocol TableDetailViewType: AnyObject {
    func load(document: HtmlDocument)
    func changeHighlightingMode(_ isOn: Bool)
    func hideTrademarks()
    func revealTrademarks()
    func revealDosages()
    /// Presents the HealthProfessionalsDisclaimer.
    /// - Parameters:
    ///   - completion: A completion that will be called with the user's disclaimer choice.
    func showDisclaimerDialog(completion: @escaping (Bool) -> Void)
}

final class TableDetailViewController: UIViewController, TableDetailViewType {

    private let presenter: TableDetailPresenterType
    private var bridge: WebViewBridge?
    private var webView: WKWebView?
    private let handler: LibraryArchiveSchemeHandler
    private var document: HtmlDocument?

    init(presenter: TableDetailPresenterType, handler: LibraryArchiveSchemeHandler) {
        self.presenter = presenter
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Library.LearningCard.TableDetailView.title
        let bridge = WebViewBridge(delegate: presenter)

        let configuration = bridge.webViewConfiguration
        configuration.setURLSchemeHandler(handler, forURLScheme: LibraryArchiveSchemeHandler.scheme) // Loads css from archive
        configuration.setURLSchemeHandler(CommonBundleSchemeHandler(), forURLScheme: CommonBundleSchemeHandler.scheme)  // Loads fonts from bundle

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear

        view.backgroundColor = .backgroundPrimary

        configureWebView(webView)

        self.webView = webView
        self.bridge = bridge
        presenter.view = self
    }

    func load(document: HtmlDocument) {
        self.document = document
        setup(document: document)
    }

    func changeHighlightingMode(_ isOn: Bool) {
        guard let webView = webView else { return }
        bridge?.call(.changeHighlightingMode(isOn), on: webView)
    }

    func hideTrademarks() {
        guard let webView = webView else { return }
        bridge?.call(.hideTrademarks, on: webView)
    }

    func revealTrademarks() {
        guard let webView = webView else { return }
        bridge?.call(.revealTrademarks, on: webView)
    }

    func revealDosages() {
        guard let webView = webView else { return }
        bridge?.call(.revealDosages, on: webView)
    }

    func showDisclaimerDialog(completion: @escaping (Bool) -> Void) {
        UIAlertMessagePresenter.presentHealthcareDisclaimer(in: self, didAgree: completion)
    }

    private func configureWebView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.constrainEdges(to: view)
    }

    private func setup(document: HtmlDocument) {
        bridge?.resetState()
        let baseURL = LibraryArchiveSchemeHandler.baseUrl() // Required to load css from archive
        webView?.loadHTMLString(document.asHtml, baseURL: baseURL)
    }
}

// WORKAROUND:
// On initial display the full width of the table should be visible. This was previously possible via
// <meta name="viewport" content="width=device-width" /> as set via HTMLDocument.swift
// The behavior of this attribute has changed however. Its still needed
// in order to make the website wrap to the devices screen width.
// (Does not wrap and zooms out very far until no element wraps when omitted)
// It does not work in the table context. The table sits in a wrapper and has its own specific width
// (which we want to preserve). Hence we zoom the page to the tables width via the logic below.
// This requires loading the page, getting the tables width
// and then reloadign it while applying the proper page width ....
extension TableDetailViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
        // document is not nil if it just has been initially loaded and why want to adjust the webview only once
        // hence we nil it immediately once we get here the first time
        guard var document else { return }
        self.document = nil

        // In case the tableview that should be displayed is wider than the viewport:
        // Readjust the viewport to the tableviews width (== zoom out to show the whole tables width)
        let jsString = "[document.querySelectorAll('table')[0].offsetWidth, document.body.offsetWidth]"
        webView.evaluateJavaScript(jsString) { [weak self] result, _ in
            guard
                let result = result as? [Int],
                let tableWidth = result.first,
                let bodyWidth = result.last
            else { return }

            if tableWidth > bodyWidth {
                // Another approach would have been to always set this meta tag
                // but that leads to "thin" tables becoming unnecessaryly wide
                // hence we do it conditionally for wide tables only ...
                let tag = HtmlDocument.Tag.meta("viewport", "width=\(tableWidth)")
                document.addHeaderTag(tag)
                self?.setup(document: document)
            }
        }
    }
}
