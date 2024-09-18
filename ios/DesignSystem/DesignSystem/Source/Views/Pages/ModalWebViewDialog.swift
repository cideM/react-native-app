//
//  ModalWebViewDialog.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 30.04.24.
//

import UIKit
import WebKit
import Localization

public class ModalWebViewDialog: UIView {

    // MARK: - Init

    public required init(config: WKWebViewConfiguration? = nil) {
        self.config = config
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        commonInit()
    }

    @available(*, unavailable) override public init(frame: CGRect) {
        fatalError("Initializer not supported")
    }

    @available(*, unavailable) public required init?(coder: NSCoder) {
        fatalError("Initializer not supported")
    }

    // MARK: - Getters

    public func availableContentWidth() -> CGFloat {
        webView.bounds.width
    }

    // MARK: - Setters

    public func set(callToAction title: String, callback: @escaping () -> Void) {
        button.setTitle(title, for: .normal)
        self.actionCallback = callback
    }

    public func set(urlCallback: @escaping (URL) -> Void) {
        self.urlCallback = urlCallback
    }

    public func set(html: String, contentHeight: CGFloat) {
        let height = contentHeight + .spacing.xl // pseudo random padding to adjust for html content margin
        webViewHeight?.constant = height
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.spinner.stopAnimating()
            self?.webView.loadHTMLString(html, baseURL: nil)
            self?.button.isEnabled = true
        }
    }

    // MARK: - Private methods

    func commonInit() {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        backgroundColor = .black.withAlphaComponent(0.6)

        addSubview(stackView)
        stackView.addArrangedSubview(webView)

        if isIpad {
            // Button is offset to the right and smaller on iPad ...
            stackView.addArrangedSubview(
                UIStackView(arrangedSubviews: [UIView(), button])
            )
        } else {
            stackView.addArrangedSubview(button)
        }

        [
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -.spacing.s),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: .spacing.s)
        ].forEach {
            $0.priority = .default
            $0.isActive = true
        }

        [
            safeAreaLayoutGuide.topAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor, constant: -.spacing.m),
            safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: .spacing.m),
            centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ].forEach {
            $0.priority = .required // Must be higher than the prioprity via calculator.calculateSize()
            $0.isActive = true
        }

        // Dialog does not stretch over the screen horizontally on iPad
        if isIpad {
            [
                stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 580),
                stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 640)
            ].forEach {
                $0.priority = .required // Must be higher than the prioprity via calculator.calculateSize()
                $0.isActive = true
            }
        }

        // Center spinner in stackview, hence not "arrangedSubview"
        addSubview(spinner)
        spinner.center(in: webView)
        spinner.startAnimating()

        let constraint = webView.heightAnchor.constraint(equalToConstant: 44)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        webViewHeight = constraint
    }

    @objc private func buttonPressed(sender: AnyObject) {
        actionCallback?()
    }

    // MARK: - Private vars

    private var actionCallback: (() -> Void)?
    private var urlCallback: ((URL) -> Void)?

    private var webViewHeight: NSLayoutConstraint?

    private let stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.layoutMargins = .init(all: .spacing.m)
        view.isLayoutMarginsRelativeArrangement = true
        view.backgroundColor = .backgroundPrimary
        view.clipsToBounds = true
        view.layer.cornerRadius = .radius.m
        view.spacing = 8
        return view
    }()

    private var config: WKWebViewConfiguration?
    private lazy var webView: WKWebView = { // lazy cause refers to self
        let view = WKWebView(frame: .zero, configuration: config ?? .init())
        view.isOpaque = false // required to avoid white background in darkmode
        view.backgroundColor = .clear // required to avoid white background in darkmode
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        return view
    }()

    private lazy var button: PrimaryButton = { // lazy cause refers to self
        let view = PrimaryButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        view.isEnabled = false
        view.contentEdgeInsets = .init(top: 0, left: .spacing.m, bottom: 0, right: .spacing.m)
        return view
    }()

    private let spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()
}

extension ModalWebViewDialog: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            urlCallback?(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
