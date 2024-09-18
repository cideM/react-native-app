//
//  InArticleSearchView.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import WebKit

/// @mockable
protocol InArticleSearchViewType: AnyObject {
    var searchText: String? { get }
    func startSearch(for query: String, completion: @escaping (Result<InArticleSearchResponse?, BridgeError>) -> Void)
    func goToQueryResultItem(withId queryResultId: InArticleResultIndentifier)
    func stopSearch(with id: InArticleSearchResponseIdentifier?)
    func setSearchLabelText(_ text: String)
}

final class InArticleSearchView: DiscardTouchView, InArticleSearchViewType {

    var searchText: String? {
        searchTextField.text
    }

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    // swiftlint:disable implicitly_unwrapped_optional
    private var presenter: InArticleSearchPresenterType!
    private var bridge: WebViewBridge!
    private var webView: WKWebView!
    // swiftlint:enable implicitly_unwrapped_optional

    private var keyboardConstraintUpdater: KeyboardConstraintUpdater?

    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchLabel: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchToolbar: UIView!

    @IBAction private func previousButtonTapped(_ sender: UIButton) {
        presenter?.goToPreviousSearchResult()
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        presenter?.goToNextSearchResult()
    }

    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        presenter?.cancelSearch()
    }

    @IBAction private func searchTextFieldTextDidChange(_ sender: UITextField) {
        presenter?.searchTextDidChange(sender.text ?? "")
    }

    static func view(with presenter: InArticleSearchPresenterType, bridge: WebViewBridge, webView: WKWebView) -> InArticleSearchView {
        let inArticleSearchView = InArticleSearchView.fromNib()!  // swiftlint:disable:this force_unwrapping
        inArticleSearchView.presenter = presenter
        inArticleSearchView.bridge = bridge
        inArticleSearchView.webView = webView
        return inArticleSearchView
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        searchToolbar.layer.shadowColor = UIColor.shadow.cgColor
        searchToolbar.layer.shadowOpacity = 0.3
        searchToolbar.layer.shadowOffset = CGSize(width: 0, height: -1)
        searchToolbar.layer.shadowRadius = 2
        searchToolbar.backgroundColor = .backgroundSecondary
        searchTextField.backgroundColor = .backgroundPrimary
        keyboardConstraintUpdater = KeyboardConstraintUpdater(rootView: self, constraints: [bottomConstraint])
        keyboardConstraintUpdater?.isEnabled = true

        leftButton.tintColor = .iconPrimary
        rightButton.tintColor = .iconPrimary

        layoutIfNeeded()

        self.searchTextField.becomeFirstResponder()
    }

    func startSearch(for query: String, completion: @escaping (Result<InArticleSearchResponse?, BridgeError>) -> Void) {
        bridge.query(WebViewBridge.QueryFactory.query(query), on: webView, completion: completion)
    }

    func goToQueryResultItem(withId queryResultId: InArticleResultIndentifier) {
        bridge.call(.scrollToQueryResult(queryResultId), on: webView)
    }

    func stopSearch(with id: InArticleSearchResponseIdentifier?) {
        if let id = id { bridge.call(.disposeQuery(id), on: webView) }
        searchTextField.resignFirstResponder()
        removeFromSuperview()
    }

    func setSearchLabelText(_ text: String) {
        searchLabel.text = text
    }
}
