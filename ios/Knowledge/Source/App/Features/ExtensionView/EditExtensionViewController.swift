//
//  ExtensionViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 09.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import WebKit
import Localization
import DesignSystem

/// @mockable
protocol EditExtensionViewType: AnyObject {
    func setExtensionText(extensionContent: String)
    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction])
}

final class EditExtensionViewController: UIViewController, EditExtensionViewType {

    private var presenter: EditExtensionPresenterType
    private var bridge: FroalaWebViewBride?
    private var webView: FroalaWebView?
    private let toolbar = ExtensionToolbar()
    private weak var currentLoadingOverlay: UIView?

    private let library: LibraryType
    @Inject private var monitor: Monitoring

    init(presenter: EditExtensionPresenterType, library: LibraryType) {
        self.presenter = presenter
        self.library = library
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Note.title
        view.backgroundColor = .backgroundPrimary
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveExtension))
        navigationItem.rightBarButtonItem = saveButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelChanges))
        navigationItem.leftBarButtonItem = cancelButton

        let bridge = FroalaWebViewBride()
        self.bridge = bridge
        let webView = FroalaWebView(frame: .zero, configuration: bridge.webViewConfiguration)
        configureWebView(webView)
        self.webView = webView

        #if DEBUG
        if #available(iOS 17, *) {
            // This is required since iOS17 to be able to inspect any WKWebView via Safari debugger
            webView.isInspectable = true
        }
        #endif

        setIsRefreshing(true)

        // Load the editor
        let editorURL = Bundle.main.url(forResource: "extension-editor", withExtension: "html", subdirectory: "froala-editor/html/")! // swiftlint:disable:this force_unwrapping
        let editorHTMLString = try! String(contentsOf: editorURL).replacingOccurrences(of: "EXTENSION_EDITOR_PLACEHOLDER", with: L10n.Note.placeholder) // swiftlint:disable:this force_try
        let baseURL = editorURL.deletingLastPathComponent()
        webView.loadHTMLString(editorHTMLString, baseURL: baseURL)
    }

    private func newLoadingOverlay() -> UIView {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        view.addSubview(activityIndicator)
        view.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        return view
    }

    private func setIsRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            guard currentLoadingOverlay == nil else { return }
            let newOverlay = newLoadingOverlay()
            view.addSubview(newOverlay)
            newOverlay.constrainEdges(to: view)
            currentLoadingOverlay = newOverlay
        } else {
            currentLoadingOverlay?.removeFromSuperview()
            currentLoadingOverlay = nil
        }
    }

    private func configureWebView(_ webView: FroalaWebView) {
        webView.backgroundColor = .backgroundPrimary
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.constrainEdges(to: view)
        webView.navigationDelegate = self
        webView.accessoryView = toolbar
        setupToolbarActions()
    }

    private func setupToolbarActions() {
        toolbar.boldButton.touchUpInsideActionClosure = { [weak self] in self?.setBold() }
        toolbar.italicButton.touchUpInsideActionClosure = { [weak self] in self?.setItalic() }
        toolbar.underlineButton.touchUpInsideActionClosure = { [weak self] in self?.setUnderline() }
        toolbar.orderedListButton.touchUpInsideActionClosure = { [weak self] in self?.insertOrderedList() }
        toolbar.unorderedListButton.touchUpInsideActionClosure = { [weak self] in self?.insertUnorderedList() }
        toolbar.undoButton.touchUpInsideActionClosure = { [weak self] in self?.undo() }
        toolbar.redoButton.touchUpInsideActionClosure = { [weak self] in self?.redo() }
    }

    @objc private func saveExtension() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.getExtensionHtml(), on: webView) { [weak self] result in
            switch result {
            case .success(let note):
                if let note = note {
                    self?.presenter.saveExtension(with: note)
                }
            case .failure:
                self?.monitor.error("Something went wrong when 'getExtensionHtml' brige call is called!", context: .none)
            }
        }
    }

    @objc private func cancelChanges() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.getExtensionHtml(), on: webView) { [weak self] result in
            switch result {
            case .success(let note):
                if let note = note {
                    self?.presenter.cancelChanges(with: note)
                }
            case .failure:
                self?.presenter.cancelChanges(with: "")
            }
        }
    }

    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction]) {
           UIAlertMessagePresenter(presentingViewController: self).present(message, actions: actions)
    }

    func setExtensionText(extensionContent: String) {
         guard let webView = self.webView else { return }
         self.bridge?.call(FroalaWebViewBride.Calls.setText(extensionContent: extensionContent), on: webView)
     }

    private func setBold() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.toggleBold(), on: webView)
    }

    private func setItalic() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.toggleItalic(), on: webView)
    }

    private func setUnderline() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.toggleUnderline(), on: webView)
    }

    private func undo() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.undo(), on: webView)
    }

    private func redo() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.redo(), on: webView)
    }

    private func insertOrderedList() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.insertOrderedList(), on: webView)
    }

    private func insertUnorderedList() {
        guard let webView = webView else { return }
        bridge?.call(FroalaWebViewBride.Calls.insertUnorderedList(), on: webView)
    }
}

extension EditExtensionViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlAsString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }
        if urlAsString.hasPrefix("file://") {
            // Allow local files to be loaded (images, stylesheets, javascript, etc.)
            return decisionHandler(.allow)
        } else if urlAsString == "js:init" {
            presenter.view = self
            setIsRefreshing(false)

            // Never load a javascript URL
            return decisionHandler(.cancel)
        } else {
            // Open external links
            if let url = navigationAction.request.url,
                ["http", "https"].contains(url.scheme) {
                presenter.openURL(url)
            }
            decisionHandler(.cancel)
        }
    }
}
