//
//  PharmaPageViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 04.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import Common
import DesignSystem
import Localization
import Domain

/// @mockable
protocol PharmaPageViewType: AnyObject {
    func setTitle(_ title: String)
    func setIsLoading(_ isLoading: Bool)
    func add(viewControllers: [UIViewController])
    func setShowsPocketCard(_ showsCard: Bool)
    func scrollTo(_ page: PharmaPage, animated: Bool)
    func showDisclaimerDialog(completion: @escaping (Bool) -> Void)
    func presentSubviewMessage(_ error: PresentableMessageType, actions: [MessageAction])
    func addCloseButton()
}

enum PharmaPage: Int {
    case pocketCard = 0
    case ifap
}

extension PharmaPageViewController: PharmaPageViewType {

    func setTitle(_ title: String) {
        self.title = title
    }

    func setShowsPocketCard(_ showsCard: Bool) {
        if showsCard {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
            tabs.selectSegment(at: 1, isAnimated: false)
            tabs.disableSegement(at: 0)
        }
    }

    func scrollTo(_ page: PharmaPage, animated: Bool) {
        scrollTo(index: page.rawValue, animated: animated)
        tabs.selectSegment(at: page.rawValue, isAnimated: false)
    }

    func setIsLoading(_ isLoading: Bool) {
        isLoading ? activityIndicatorView.startLogoAnimation() : activityIndicatorView.stopLogoAnimation()
        verticalStackView.isHidden = isLoading
    }

    func add(viewControllers: [UIViewController]) {
        for viewController in viewControllers {
            addChild(viewController)
            horizontalStackView.addArrangedSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
    }

    func showDisclaimerDialog(completion: @escaping (Bool) -> Void) {
        UIAlertMessagePresenter.presentHealthcareDisclaimer(in: self, didAgree: completion)
    }

    func presentSubviewMessage(_ error: PresentableMessageType, actions: [MessageAction]) {
        SubviewMessagePresenter(rootView: view).present(error, actions: actions)
    }

    func addCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain) { [weak self] _ in
            self?.presenter?.close()
        }
    }
}

class PharmaPageViewController: UIViewController {

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var tabs: TabsControl = {
        let view = TabsControl(frame: .zero, actions: [
            .init(title: .init(string: L10n.Substance.TabTitle.factSheet)) { [weak self] index in
                self?.scrollTo(index: index, animated: true)
            },
            .init(title: .init(string: L10n.Substance.TabTitle.ifap)) { [weak self] index in
                self?.scrollTo(index: index, animated: true)
            }
        ])
        view.backgroundColor = .backgroundPrimary
        view.heightAnchor.constraint(equalToConstant: TabsControl.defaultHeight).isActive = true
        view.showsDivider = true
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        view.isDirectionalLockEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()

    private lazy var activityIndicatorView: AmbossLogoActivityIndicator = {
        let view = AmbossLogoActivityIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var stackViewWidth: NSLayoutConstraint?
    private weak var presenter: PharmaPagePresenterType?
    private var lastIndex: Int?

    // MARK: - Init

    required init(presenter: PharmaPagePresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Template methods

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.view = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Nothing has changed layout wise, hence keep constraints
        // This might happen if the view was covered by a modal ...
        guard Int(stackViewWidth?.multiplier ?? 0) != children.count else { return }

        if let stackViewWidth {
            horizontalStackView.removeConstraint(stackViewWidth)
        }
        let multiplier = CGFloat(children.count)
        stackViewWidth = horizontalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: multiplier)
        stackViewWidth?.isActive = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        let index = scrollView.index // <- take before rotation, otherwise will be wrong
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: view) { [weak self] _ in
            guard let self else { return }
            // This is only here to correct the offset after rotation (otherwise half page is visible)
            // didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) is deprecated
            // so this is the best we can do. We could filter here if the device was really rotated
            // but this is really complicated, so what the heck, we'll just always scroll ...
            scrollTo(index: index, animated: true)
        }
    }

    // MARK: - Helpers

    private func setup() {

        // This is necessary in order to make the content respect safe areas when in landscape
        let scrollViewWrapper = UIView()
        scrollViewWrapper.backgroundColor = .backgroundPrimary
        scrollViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        scrollViewWrapper.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollViewWrapper.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollViewWrapper.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollViewWrapper.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewWrapper.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        view.addSubview(verticalStackView)
        verticalStackView.constrainEdges(to: view)
        verticalStackView.addArrangedSubview(tabs)
        verticalStackView.addArrangedSubview(scrollViewWrapper)

        scrollView.addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: horizontalStackView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor)
        ])

        view.addSubview(activityIndicatorView)
        activityIndicatorView.constrainEdges(to: view)
    }

    func scrollTo(index: Int, animated: Bool) {
        guard children.count > index else { return }
        let viewController = children[index]
        var frame = viewController.view.frame
        frame.origin = scrollView.convert(viewController.view.frame.origin, to: scrollView)
        if frame.origin.x != scrollView.contentOffset.x {
            scrollView.scrollRectToVisible(frame, animated: animated)
        }
        lastIndex = index

        // If it's animated then it was invoked by the user, hence track ...
        if animated {
            presenter?.didScrollToPage(at: index)
        }
    }
}

extension PharmaPageViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int((scrollView.contentOffset.x / scrollView.frame.size.width).rounded())
        guard lastIndex != index else { return }
        lastIndex = index
        tabs.selectSegment(at: index)
        presenter?.didScrollToPage(at: index)
    }
}

fileprivate extension UIScrollView {
    var index: Int {
        guard bounds.size.width != 0 else { return 0 }
        return Int(round(contentOffset.x / bounds.size.width))
    }
}
