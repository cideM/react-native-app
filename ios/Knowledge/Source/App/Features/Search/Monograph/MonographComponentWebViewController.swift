//
//  MonographComponentWebViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 13.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit
import WebKit

/// @mockable
protocol MonographComponentWebViewType: AnyObject {
    func load(monographComponent: MonographComponent)
}

final class MonographComponentWebViewController: UIViewController, MonographComponentWebViewType {

    private let presenter: MonographComponentWebViewPresenterType
    private var bridge: MonographWebViewBridge?
    private var webView: WKWebView?
    private var currentComponent: MonographComponent?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.closeButton.image, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(presenter: MonographComponentWebViewPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        view.addSubview(doneButton)
        view.addSubview(titleLabel)
        setupHeaderConstraints()

        let bridge = MonographWebViewBridge(delegate: presenter)
        let webView = WKWebView(frame: .zero, configuration: bridge.webViewConfiguration)
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear
        self.webView = webView
        self.bridge = bridge
        view.addSubview(webView)

        presenter.view = self
    }

    func load(monographComponent: MonographComponent) {
        self.currentComponent = monographComponent

        switch monographComponent {
        case .references(let title, let htmlContent):
            titleLabel.attributedText = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.drugListTitleTextAttributes)
            webView?.loadHTMLString(htmlContent, baseURL: nil)
        case .table(let title, let htmlContent):
            self.title = title
            view.backgroundColor = ThemeManager.currentTheme.backgroundColor
            titleLabel.removeFromSuperview()
            doneButton.removeFromSuperview()
            webView?.loadHTMLString(htmlContent, baseURL: nil)
        case .offLabelElement(let htmlContent):
             webView?.loadHTMLString(htmlContent, baseURL: nil)
        case .tableAnnotation(let htmlContent):
            webView?.loadHTMLString(htmlContent, baseURL: nil)
        }

        setupWebViewConstraints()
    }

    private func setupHeaderConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            doneButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            doneButton.widthAnchor.constraint(equalToConstant: 24),
            doneButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupWebViewConstraints() {
        guard let webView = webView else { return }
        webView.translatesAutoresizingMaskIntoConstraints = false

        switch currentComponent {
        case .table:
            webView.constrainEdges(to: view)
        default:
            let layoutGuide = view.safeAreaLayoutGuide
            let webViewTopConstraint = webView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 8)
            webViewTopConstraint.priority = UILayoutPriority(999)
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 0),
                webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: 0),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                webViewTopConstraint
            ])
        }
    }

    @objc func doneButtonTapped() {
        presenter.dismissView()
    }
}

extension MonographComponentWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, _ in
            guard let self = self else { return }
            if let height = result as? CGFloat {
                let topSpacing: CGFloat = 32
                self.preferredContentSize = CGSize(width: self.view.bounds.width, height: height + self.doneButton.bounds.height + self.view.safeAreaInsets.bottom + topSpacing)
            }
        }
    }
}
