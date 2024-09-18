//
//  LearningCardViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 10.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import WebKit
import Localization
import DesignSystem

final class LearningCardViewController: UIViewController, LearningCardViewType {

    private let touchDownScaleFactor = 0.9

    override var title: String? {
        didSet {
            navigationItem.titleView = navbarTitleView(title: title)
        }
    }

    var canNavigateToPrevious = true {
        didSet {
            toolbarBackButton.isEnabled = canNavigateToPrevious
        }
    }

    var canNavigateToNext = true {
        didSet {
            toolbarForwardButton.isEnabled = canNavigateToNext
        }
    }

    var canOpenAllSections = true {
        didSet {
            toolbarUnfoldButton.setTitle(canOpenAllSections ? L10n.LearningCardToolbar.Button.Title.unfold : L10n.LearningCardToolbar.Button.Title.fold)
            toolbarUnfoldButton.setImage(canOpenAllSections ? Asset.Icon.openAllSections.image : Asset.Icon.closeAllSections.image)
        }
    }

    var isFavorite = false {
        didSet {
            let image = isFavorite ? Asset.Icon.favoriteFilled.image : Asset.Icon.favorite.image
            favoriteItemButton.setImage(image, for: .normal)
            favoriteItemButton.setImage(image, for: .highlighted)
        }
    }

    private weak var presenter: LearningCardPresenterType?

    private lazy var bridge = WebViewBridge(delegate: self)
    private lazy var webView: WKWebView = {
        var configuration = bridge.webViewConfiguration
        configuration.setURLSchemeHandler(WeakURLSchemeHandlerWrapper(libraryArchiveSchemeHandler), forURLScheme: LibraryArchiveSchemeHandler.scheme) // Loads learning card from archive
        configuration.setURLSchemeHandler(CommonBundleSchemeHandler(), forURLScheme: CommonBundleSchemeHandler.scheme) // Loads fonts from bundle
        let webView = WKWebView(frame: .zero, configuration: bridge.webViewConfiguration)
        webView.isInspectableInDebugAndQABuilds = true
        webView.isOpaque = false
        webView.backgroundColor = .canvas
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var toolbarBackButton: LearningCardToolbar.Button = {
        LearningCardToolbar.Button(title: L10n.LearningCardToolbar.Button.Title.back, image: Asset.Icon.historyPrevious.image) { [weak self] in
            self?.presenter?.goToPreviousLearningCard()
        }
    }()
    private lazy var toolbarForwardButton: LearningCardToolbar.Button = {
        LearningCardToolbar.Button(title: L10n.LearningCardToolbar.Button.Title.next, image: Asset.Icon.historyNext.image) { [weak self] in
            self?.presenter?.goToNextLearningCard()
        }
    }()
    private lazy var toolbarUnfoldButton: LearningCardToolbar.Button = {
        LearningCardToolbar.Button(title: L10n.LearningCardToolbar.Button.Title.unfold, image: Asset.Icon.openAllSections.image) { [weak self] in
            // Doing this so weirdly cause can not access "self" before "super.init"
            // "presenter.view" actually is "self" ...
            self?.presenter?.view?.canOpenAllSections ?? false ? self?.presenter?.openAllSections() : self?.presenter?.closeAllSections()
        }
    }()
    private lazy var toolbarFindButton: LearningCardToolbar.Button = {
        LearningCardToolbar.Button(title: L10n.LearningCardToolbar.Button.Title.find, image: Asset.Icon.inArticleSearch.image) { [weak self] in
            self?.presenter?.showInArticleSearch()
        }
    }()
    private lazy var toolbarMinimapButton: LearningCardToolbar.Button = {
        LearningCardToolbar.Button(title: L10n.LearningCardToolbar.Button.Title.index, image: Asset.Icon.index.image) { [weak self] in
            self?.presenter?.showMiniMap()
        }
    }()
    private lazy var toolbar: LearningCardToolbar = {
        let view = LearningCardToolbar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGroup(.leftAligned(items: [toolbarBackButton, toolbarForwardButton]))
        view.addGroup(.seperator(item: LearningCardToolbar.Separator(width: 16)))
        view.addGroup(.rightAligned(items: [toolbarUnfoldButton, toolbarFindButton, toolbarMinimapButton]))
        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.backgroundColor = .canvas
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var subviewErrorPresenter = SubviewMessagePresenter(rootView: view)
    @Inject private var monitor: Monitoring

    private lazy var favoriteItemButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Icon.favorite.image, for: .normal)
        button.setImage(Asset.Icon.favorite.image, for: .highlighted)
        button.addTarget(self, action: #selector(favoriteButtonTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(favoriteButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(favoriteButtonTouchUpOutside(_:)), for: .touchUpOutside)
        return button
    }()

    private lazy var favoriteItem: UIBarButtonItem = {
        UIBarButtonItem(customView: favoriteItemButton)
    }()

    private lazy var moreItem: UIBarButtonItem = {
        UIBarButtonItem(image: Asset.Icon.ellipsis.image, style: .plain) { [weak self] _ in
            self?.presenter?.showLearningCardOptions()
        }
    }()

    private let libraryArchiveSchemeHandler: LibraryArchiveSchemeHandler
    private let learningCardTracker: LearningCardTrackerType

    private var webViewNavigationCompletion: (url: URL, onSuccess: (() -> Void))?
    private var ids = [String]()

    init(presenter: LearningCardPresenterType, learningCardTracker: LearningCardTrackerType, handler: LibraryArchiveSchemeHandler) {
        self.presenter = presenter
        self.libraryArchiveSchemeHandler = handler
        self.learningCardTracker = learningCardTracker

        super.init(nibName: nil, bundle: nil)

        [toolbarBackButton, toolbarForwardButton, toolbarUnfoldButton, toolbarFindButton, toolbarMinimapButton].forEach {
            $0.setTitleColor(.textSecondary, for: .normal)
            $0.setTitleColor(.textSecondary, for: .highlighted)
            $0.setTitleColor(.textSecondary, for: .disabled)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        addToolbar()
        configureWebView(webView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        presenter?.view = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // because the toolbar might be shown by the gallery
        // once we update the learningcard to use a "real" toolbar as well
        // we can remove this
        navigationController?.isToolbarHidden = true
    }

    func setTitle(_ title: String) {
        self.title = title
    }

    func load(learningCard: LearningCardIdentifier, onSuccess: @escaping () -> Void) {
        assert(Thread.isMainThread)

        webView.stopLoading()
        bridge.resetState()

        let url = LibraryArchiveSchemeHandler.url(for: learningCard)
        let request = URLRequest(url: url)

        webViewNavigationCompletion = (url, onSuccess)
        webView.load(request)
    }

    private func configureWebView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        setupWebViewContraints(webView)
    }

    func addToolbar() {
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: LearningCardToolbar.toolbarHeight)
        ])
    }

    func setupWebViewContraints(_ webView: WKWebView) {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }

    @objc private func shareButtonTapped(_ sender: UIBarButtonItem) {
        presenter?.shareLearningCard()
    }

    func canGoTo(anchor: LearningCardAnchorIdentifier) -> Bool {
        ids.contains(anchor.value)
    }

    func go(to anchor: LearningCardAnchorIdentifier, question: QBankQuestionIdentifier?) {
        bridge.call(.scrollToAnchor(anchor, question), on: webView)
    }

    func setIsLoading(_ isLoading: Bool) {
        webView.isHidden = isLoading
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }

    func presentLearningCardError(_ error: PresentableMessageType, _ actions: [MessageAction]) {
        setNavbarOptions(visible: false)
        subviewErrorPresenter.present(error, actions: actions)
    }

    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(message, actions: actions)
    }

    func closeAllSections() {
        bridge.call(.closeAllSections, on: webView)
    }

    func openAllSections() {
        bridge.call(.openAllSections, on: webView)
    }

    func changeHighlightingMode(_ isOn: Bool) {
        bridge.call(.changeHighlightingMode(isOn), on: webView)
    }

    func changeHighYieldMode(_ isOn: Bool) {
        bridge.call(.changeHighYieldMode(isOn), on: webView)
    }

    func changePhysikumFokusMode(_ isOn: Bool) {
        bridge.call(.changePhysikumFokusMode(isOn), on: webView)
    }

    func changeLearningRadarMode(_ isOn: Bool) {
        bridge.call(.changeLearningRadarMode(isOn), on: webView)
    }

    func activateStudyObjective(_ studyObjective: String) {
        bridge.call(.activateStudyObjective(studyObjective), on: webView)
    }

    func setExtensions(_ extensions: [Extension]) {
        bridge.call(.setExtensions(extensions), on: webView)
    }

    func setSharedExtensions(_ sharedExtensions: [SharedExtension]) {
        bridge.call(.setSharedExtensions(sharedExtensions), on: webView)
    }

    func setPhysicianModeIsOn(_ isOn: Bool) {
        bridge.call(.setPhysicianModeIsOn(isOn), on: webView)
    }

    func getLearningCardModes(completion: @escaping (Result<[String], BridgeError>) -> Void) {
        bridge.query(WebViewBridge.QueryFactory.learnigCardModes(), on: webView, completion: completion)
    }

    func setFontSize(size: Float) {
        bridge.call(.setFontSize(size), on: webView)
    }

    func hideTrademarks() {
        bridge.call(.hideTrademarks, on: webView)
    }

    func revealTrademarks() {
        bridge.call(.revealTrademarks, on: webView)
    }

    func revealDosages() {
        bridge.call(.revealDosages, on: webView)
    }

    func showError(title: String, message: String) {
        UIAlertMessagePresenter(presentingViewController: self).present(title: title, message: message, actions: [.dismiss])
    }

    func showInArticleSearchView() {
        let inArticleSearchPresenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        let inArticleSearchView = InArticleSearchView.view(with: inArticleSearchPresenter, bridge: bridge, webView: webView)
        inArticleSearchPresenter.view = inArticleSearchView

        view.addSubview(inArticleSearchView)
        inArticleSearchView.constrainEdges(to: view)
    }

    func setWrongAnsweredQuestions(questionIDs: [QBankQuestionIdentifier]) {
        bridge.call(.setWrongAnsweredQuestions(questionIDs), on: webView)
    }

    func showDisclaimerDialog(completion: @escaping (Bool) -> Void) {
        UIAlertMessagePresenter.presentHealthcareDisclaimer(in: self, didAgree: completion)
    }

    @IBAction
    private func favoriteButtonTouchUpInside(_ sender: UIButton) {
        // We need to wrap the identity call here in a transaction to make sure it is rendered
        // before we start the explosion animation
        CATransaction.begin()
        sender.transform = CGAffineTransformIdentity
        CATransaction.commit()
        try? animateButtonExplosion(sender)
        presenter?.toggleIsFavorite()
    }

    static let explosionScaleFactor = 2.0
    static let explosionAnimationDuration = 0.4
    private func animateButtonExplosion(_ button: UIButton) throws {
        guard let imageView = button.imageView else { return }
        let archivedLayer = try NSKeyedArchiver.archivedData(withRootObject: imageView.layer, requiringSecureCoding: false)
        guard let imageViewLayerCopy = try NSKeyedUnarchiver.unarchivedObject(ofClass: CALayer.self, from: archivedLayer) else { return }
        imageView.layer.superlayer?.addSublayer(imageViewLayerCopy)
        imageViewLayerCopy.bounds = button.bounds

        CATransaction.begin()
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = CATransform3DIdentity
        scaleAnimation.toValue = Self.explosionScaleFactor

        scaleAnimation.duration = Self.explosionAnimationDuration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 0.5
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = Self.explosionAnimationDuration
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        CATransaction.setCompletionBlock {
            imageViewLayerCopy.removeFromSuperlayer()
        }
        imageViewLayerCopy.add(scaleAnimation, forKey: scaleAnimation.keyPath)
        imageViewLayerCopy.add(alphaAnimation, forKey: alphaAnimation.keyPath)

        CATransaction.commit()
    }

    @IBAction
    private func favoriteButtonTouchUpOutside(_ sender: UIButton) {
        sender.transform = CGAffineTransformIdentity
    }

    @IBAction
    private func favoriteButtonTouchDown(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: touchDownScaleFactor, y: touchDownScaleFactor)
    }
}

extension LearningCardViewController: WebViewBridgeDelegate {
    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback) {
        presenter?.webViewBridge(bridge: bridge, didReceiveCallback: callback)
        switch callback {
        case .`init`:
            if let anchor = webView.url?.queryItem(forName: "anchor")?.value {
                let questionIdString = webView.url?.queryItem(forName: "questionId")?.value
                let questionId = questionIdString.map { QBankQuestionIdentifier(value: $0) }
                go(to: LearningCardAnchorIdentifier(value: anchor), question: questionId)
            }
        default: break
        }
    }
}

extension LearningCardViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated, ["http", "https"].contains(url.scheme) {
            presenter?.openURL(url)
            return decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }

    // swiftlint:disable implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setNavbarOptions(visible: true)

        // Extracting all the ids from the html document. In order to check elsewhere
        // if ids delivered by the backend actually exist. Before we attempt to jump to them.
        let allIDsAsArray = "Array.prototype.slice.call(document.querySelectorAll('*[id]')).map(e => e.id);"
        webView.evaluateJavaScript(allIDsAsArray) { [weak self] result, _ in
            self?.ids = result as? [String] ?? []

            if let completion = self?.webViewNavigationCompletion, completion.url == webView.url {
                completion.onSuccess()
                self?.webViewNavigationCompletion = nil
            }
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // This is invoked only via failures in LibraryArchiveSchemeHandler and BundleSchemeHandler
        if webViewNavigationCompletion?.url == webView.url {
            webViewNavigationCompletion = nil
        }

        // Chancelled error is only invoked if the user navigated away from, a page before it finished loading
        // Hence we do not need to show an error in case that happened ...
        if (error as NSError).code == -999 { return } // -999 means "cancelled"
        showError(title: L10n.Error.Generic.title, message: L10n.Error.Generic.message)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setNavbarOptions(visible: false)
        monitor.error(error.localizedDescription, context: .none)
        if webViewNavigationCompletion?.url == webView.url {
            webViewNavigationCompletion = nil
        }
    }
    // swiftlint:enable implicitly_unwrapped_optional
}

private extension LearningCardViewController {

    func navbarTitleView(title: String?) -> UIView {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false

        [
         container.widthAnchor.constraint(greaterThanOrEqualToConstant: .greatestFiniteMagnitude),
         container.heightAnchor.constraint(equalToConstant: 24) // <- required to make the text sit properly vertically
        ].forEach {
            $0.priority = .defaultHigh // -> not ".required" cause might be compressed when screen rotates
            $0.isActive = true
        }

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = Font.bold.font(withSize: 16)
        label.numberOfLines = 1
        label.textColor = .textOnAccent

        container.addSubview(label)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: label.trailingAnchor),

            // Centering this brings it to the bottom line of the close button to its left
            // which is what we want here ...
            container.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])

        return container
    }

    func setNavbarOptions(visible: Bool) {
        navigationItem.rightBarButtonItems = visible ? [moreItem, favoriteItem] : []
    }
}
