//
//  WebViewController.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 11.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit
import WebKit
import DesignSystem

/// @mockable
public protocol WebViewControllerType: AnyObject {
    func setIsLoading(_ isLoading: Bool)
    func showError(_ error: PresentableMessageType, actions: [MessageAction])
    func loadRequest(_ request: URLRequest)
    func loadHTML(_ html: String)
}

public final class WebViewController: UIViewController, WebViewControllerType {

    private lazy var errorPresenter = SubviewMessagePresenter(rootView: self.view)

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.isInspectableInDebugAndQABuilds = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var presenter: WebViewPresenterType?

    public init(presenter: WebViewPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary

        view.addSubview(webView)
        setWebViewConstraints()
        webView.navigationDelegate = self

        view.addSubview(activityIndicatorView)
        activityIndicatorView.setAnimating(true)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        presenter?.view = self
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // WORKAROUND:
        // This viewcontroller does not get released if the presenter is not explicitely nil'ed
        // Reason unclear. But doing it here works and releases the viewcontroller.
        // Please see here why this is important: https://miamed.atlassian.net/browse/PHEX-1177
        if isBeingDismissed || (navigationController?.isBeingDismissed ?? false) {
            presenter = nil
        }
    }

    public func setIsLoading(_ isLoading: Bool) {
        activityIndicatorView.setAnimating(isLoading)
    }

    public func showError(_ error: PresentableMessageType, actions: [MessageAction]) {
        activityIndicatorView.setAnimating(false)
        errorPresenter.present(error, actions: actions)
    }

    public func loadRequest(_ request: URLRequest) {
        activityIndicatorView.setAnimating(true)
        webView.stopLoading()
        webView.load(request)
    }

    public func loadHTML(_ html: String) {
        activityIndicatorView.setAnimating(true)
        webView.stopLoading()
        webView.loadHTMLString(html, baseURL: nil)
    }

    private func setWebViewConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}

extension WebViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        assert(presenter != nil)
        activityIndicatorView.setAnimating(false)

        // WORKAROUND: "itms-appss://" links are causing
        // a "Frame load interupted" error when we cancel the loading.
        // If the error code is 102 and url scheme is itms-appss -> We igonre the error
        let error = error as NSError
        if let failingURL = error.userInfo["NSErrorFailingURLKey"] as? NSURL,
           failingURL.scheme == "itms-appss",
           error.code == 102 {
            return
        }

        presenter?.failedToLoad(with: error)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, _ in
            guard let self = self else { return }
            if let height = result as? CGFloat {
                self.preferredContentSize = CGSize(width: self.view.bounds.width, height: round(height + self.view.layoutMargins.top + self.view.layoutMargins.bottom))
            }
        }
        activityIndicatorView.setAnimating(false)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let presenter, let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if presenter.canNavigate(to: url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            presenter.openExternally(url: url)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        assert(presenter != nil)
        presenter?.failedToLoad(with: error)
        activityIndicatorView.setAnimating(false)
    }
}
