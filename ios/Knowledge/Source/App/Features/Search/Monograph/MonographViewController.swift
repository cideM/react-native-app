//
//  MonographViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 07.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import WebKit
import DesignSystem

/// @mockable
protocol MonographViewType: AnyObject {
    func update(with title: String, html: String, query: String?)
    func showError(_ error: PresentableMessageType, actions: [MessageAction])
    func setIsLoading(_ isLoading: Bool)
    func go(to anchor: MonographAnchorIdentifier)
}

class MonographViewController: UIViewController {

    private var presenter: MonographPresenterType

    @Inject private var monitor: Monitoring
    private lazy var subviewErrorPresenter = SubviewMessagePresenter(rootView: view)

    private lazy var bridge = MonographWebViewBridge(delegate: self)
    private var webView: WKWebView?
    private lazy var activityIndicatorView: AmbossLogoActivityIndicator = {
        let view = AmbossLogoActivityIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var anchor: String?

    required init(presenter: MonographPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .canvas

        let webView = WKWebView(frame: .zero, configuration: bridge.webViewConfiguration)
        webView.isInspectableInDebugAndQABuilds = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.webView = webView

        view.addSubview(activityIndicatorView)
        activityIndicatorView.constrainEdges(to: view)

        presenter.view = self
    }
}

extension MonographViewController: MonographViewType {

    func update(with title: String, html: String, query: String?) {
        self.title = title
        let url: URL? = if let query {
            // Only the query part of this URL matters ...
            URL(string: "https://next.amboss.com/us?\(query)")
        } else {
            nil
        }
        webView?.loadHTMLString(html, baseURL: url)
    }

    func showError(_ error: PresentableMessageType, actions: [MessageAction]) {
        subviewErrorPresenter.present(error, actions: actions)
    }

    func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.activityIndicatorView.startLogoAnimation(animated: true)
        } else {
            self.activityIndicatorView.stopLogoAnimation(animated: true)
        }

        // This is kind of a workaround:
        // It's important to animate the webview's alpha change
        // If you don't the pages css seems to be applied only a split second
        // after the view became visible - which looks ugly
        UIView.animate(withDuration: AmbossLogoActivityIndicator.animationDuration) { [weak self] in
            self?.webView?.alpha = isLoading ? 0.0 : 1.0
        }
    }

    func go(to anchor: MonographAnchorIdentifier) {
        let id = "#" + anchor.value
        let javaScript = "window.mobile.scrollToElementWithId('\(id)')"
        webView?.evaluateJavaScript(javaScript) { [weak self] _, error in
            if let error = error {
                self?.monitor.error(error.localizedDescription, context: .monographs)
                self?.presenter.trackError(error)
            }
        }
    }
}

extension MonographViewController: MonographWebViewBridgeDelegate {

    func bridge(didReceive analyticsEvent: MonographWebViewBridge.AnalyticsEvent) {
        presenter.bridge(didReceive: analyticsEvent)
    }

    func bridge(didReceive event: MonographWebViewBridge.Event) {
        presenter.bridge(didReceive: event)
    }

    func bridge(didFail error: MonographWebViewBridge.Error) {
        presenter.bridge(didFail: error)
    }
}

extension MonographViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // This only makes sure any URL's that might have sneaked into the monpgraph are opened on a separate screen
        // There should not be any clickable URL's in any monograph though since those are usually opened via event: .openLinkToExternalPage
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated, ["http", "https"].contains(url.scheme) {
            let event = MonographWebViewBridge.Event.openLinkToExternalPage(url: url)
            presenter.bridge(didReceive: event)
            return decisionHandler(.cancel)
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        presenter.webViewDidFailToLoad()
        setIsLoading(false)
        monitor.error(error.localizedDescription, context: .monographs)
        presenter.trackError(error)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        setIsLoading(false)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        presenter.webViewDidFailToLoad()
        setIsLoading(false)
        monitor.error(error.localizedDescription, context: .monographs)
        presenter.trackError(error)
    }
}
