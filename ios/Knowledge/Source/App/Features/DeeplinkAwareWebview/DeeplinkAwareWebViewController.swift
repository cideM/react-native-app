//
//  DeeplinkAwareWebViewController.swift
//  Knowledge DE
//
//  Created by Manaf Alabd Alrahim on 29.08.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit
import WebKit
import DesignSystem
import Common

/// @mockable
public protocol DeeplinkAwareWebViewControllerType: AnyObject {
    func showError(_ error: PresentableMessageType, actions: [MessageAction])
    func loadRequest(_ request: URLRequest)
}

public final class DeeplinkAwareWebViewController: UIViewController, DeeplinkAwareWebViewControllerType {

    private lazy var errorPresenter = SubviewMessagePresenter(rootView: self.view)
    private var dismissClosure: (() -> Void)?

    private let webView: WKWebView = {
        let preference = WKPreferences()
        preference.isTextInteractionEnabled = false

        let config = WKWebViewConfiguration()
        config.preferences = preference

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isInspectableInDebugAndQABuilds = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.allowsLinkPreview = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = true
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

    private var presenter: DeeplinkAwareWebviewPresenterType?
    private var titleObserver: NSKeyValueObservation?

    public init(presenter: DeeplinkAwareWebviewPresenterType, initialTitle: String, dismissClosure: (() -> Void)?) {
        self.presenter = presenter
        self.dismissClosure = dismissClosure
        super.init(nibName: nil, bundle: nil)
        self.title = initialTitle
        self.hidesBottomBarWhenPushed = true
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

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: Asset.Icon.back.image, style: .plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton

        // Set the title of the webview to match the webpage title
        titleObserver = webView.observe(\.title, changeHandler: { [weak self] webView, _ in
            self?.title = webView.title
        })

        presenter?.view = self
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        dismissClosure?()
    }

    @objc func back(sender: UIBarButtonItem?) {
        // if the webview has history items the
        // back button acts as a browser back button
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
          webView.reload()
        }
    }

    public func showError(_ error: PresentableMessageType, actions: [MessageAction]) {
        activityIndicatorView.setAnimating(false)
        errorPresenter.present(error, actions: actions)
    }

    public func loadRequest(_ request: URLRequest) {
        if !webView.isLoading {
            activityIndicatorView.setAnimating(true)
            webView.stopLoading()
            webView.load(request)
        }
    }

    private func setWebViewConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DeeplinkAwareWebViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        assert(presenter != nil)
        activityIndicatorView.setAnimating(false)

        presenter?.failedToLoad(with: error)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        self.title = webView.title
        activityIndicatorView.setAnimating(false)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let presenter, let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if navigationAction.targetFrame == nil || presenter.canDeeplink(to: url) {
            // If new tab or the app can handle the url as a deeplink
            decisionHandler(.cancel)
            presenter.openInternally(url: url)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        assert(presenter != nil)
        presenter?.failedToLoad(with: error)
        activityIndicatorView.setAnimating(false)
    }
}

extension DeeplinkAwareWebViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if gestureRecognizer === navigationController?.interactivePopGestureRecognizer {
            return !webView.canGoBack
        }
        return true
    }
}
