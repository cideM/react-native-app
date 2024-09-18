//
//  GalleryImageViewController.swift
//  Knowledge
//
//  Created by CSH on 04.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import Common
import Domain
import simd
import UIKit
import Localization

final class GalleryImageViewController: UIViewController {

    let presenter: GalleryImageViewPresenterType
    var presentationControllerDismissalRecognizer: UIGestureRecognizer?

    let collapsedPanelInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
    let expandedPanelInsets = NSDirectionalEdgeInsets.zero

    var expandedPanelWidth: CGFloat {
        view.bounds.width - expandedPanelInsets.leading - expandedPanelInsets.trailing
    }

    private lazy var errorPresenter = SubviewMessagePresenter(rootView: self.view)
    private let imageView: ZoomableImageView = {
        let view = ZoomableImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // "Unclipping" these cause we shrink the view when the panel comes up
        // We do this in order to center the imageview on the remaining screen space
        // while we do not mind as much as possible of the image being still visible
        // (even outside of the view bounds) ...
        view.clipsToBounds = false
        view.imageView.clipsToBounds = false
        return view
    }()
    private(set) var imageViewBottomAnchorConstraint: NSLayoutConstraint?
    private(set) var imageViewTopAnchorConstraint: NSLayoutConstraint?

    private lazy var singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentViewController: ImageDescriptionViewController = makePanelContentViewController()
    var panel: Panel?
    var pill: PillViewController?

    init(presenter: GalleryImageViewPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var fullscreen = false
    var isAnalyticsTrackingEnabled = false
    var wasContentInitiallyCompletelyVisible = false
}

// MARK: Template methods

extension GalleryImageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Its important to clip this view, since the zoomaable image view is not clipped
        // When zoomed in this would draw over the viewcontrollers borders
        // and mess up UIPageViewController (-> GalleryViewController)
        // See "let imageView" for info why this one is not clipped
        view.clipsToBounds = true

        view.addSubview(imageView)
        let bottomAnchorConstraint = view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: panelMinHeight())
        self.imageViewBottomAnchorConstraint = bottomAnchorConstraint

        // The 'topSpace' refers to the height of the status bar
        // plus the height of the navigation bar. It was calculated
        // this way because the view's safeArea isn't acurate at
        // this point in the VC lifecycle.
        let topSpace: CGFloat = (self.navigationController?.navigationBar.bounds.height ?? 0) + (UIApplication.activeKeyWindow?.safeAreaInsets.top ?? 0)

        let topAnchorConstraint = imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topSpace)
        self.imageViewTopAnchorConstraint = topAnchorConstraint

        NSLayoutConstraint.activate([
            bottomAnchorConstraint,
            topAnchorConstraint,
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.addGestureRecognizer(singleTapGestureRecognizer)
        singleTapGestureRecognizer.require(toFail: imageView.doubleTapGestureRecognizer)

        guard let panel = makePanel(with: contentViewController) else {
            assertionFailure("Could not create panel")
            return
        }
        self.panel = panel
        panel.add(to: self)

        // Panel must be in front of pill cause pill disappears behind panel
        // when view is sliding off screen (see: GalleryViewController.scrollViewDidScroll)
        addPill(constraintTo: panel)

        view.bringSubviewToFront(panel.view)

        presenter.view = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // This is recalculated here to accomodate for orientation changes
        let topSpace: CGFloat = (self.navigationController?.navigationBar.bounds.height ?? 0) + (UIApplication.activeKeyWindow?.safeAreaInsets.top ?? 0)
        self.imageViewTopAnchorConstraint?.constant = topSpace
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if // This branch is typically taken the first time the view is displayed ...
            panel?.configuration.mode == .compact,
            contentViewController.isContentCompletelyVisible() {
            panel?.configuration.supportedModes = [.compact]
            contentViewController.setChevronIsHidden(true)
            contentViewController.setContentAlpha(1.0)
            wasContentInitiallyCompletelyVisible = true
        } else {
            // This is only possible if there is sufficient content
            // to make the panel unfold ...
            togglePanel(override: .compact)
        }

        presenter.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAnalyticsTrackingEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        togglePanel(override: .compact)
    }
}

// MARK: - Actions

extension GalleryImageViewController {

    func togglePanel(override mode: Aiolos.Panel.Configuration.Mode? = nil) {
        guard let panel = panel else { return }

        // Disabling all interactions while panel transition are in progress
        view.isUserInteractionEnabled = false
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.view.isUserInteractionEnabled = true
        }
        if let mode = mode {
            panel.configuration.mode = mode
        } else {
            switch panel.configuration.mode {
            case .minimal, .compact: panel.configuration.mode = .expanded
            case .expanded, .fullHeight: panel.configuration.mode = .compact
            }
        }
        CATransaction.commit()
    }

    @objc private func didTapImage(_ gestureRecognizer: UIGestureRecognizer) {
       setFullscreen(!fullscreen, animated: true)
    }

    func updateFullscreen(_ value: Bool) {

        self.fullscreen = value
        self.setFullscreen(value, animated: false)
    }

}

// MARK: Setters

extension GalleryImageViewController {

    func setPillVisibility(_ factor: CGFloat) {
        pill?.setPillVisibility(factor)
    }

    private func setFullscreen(_ value: Bool, animated: Bool) {

        fullscreen = value
        presenter.setFullscreen(fullscreen)
        let theme = ThemeManager.currentTheme

        if animated {
            // Hiding/showing the navigationbar affects the view bounds
            // This leads to the pill view "jumping"
            // In order to avoid that parts are shwon/hidden in different orders
            // depending if transitioning from or to fullscreen ...
            if fullscreen {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.panel?.view.alpha = 0.0
                    self?.pill?.view.alpha = 0.0
                    self?.view.backgroundColor = theme.galleryHiddenNavigationBackgroundColor
                }, completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.setNavigationBarHidden(self.fullscreen, animated: true)
                    self.panel?.configuration.mode = .compact
                })

            } else {
                // Need to wait till navbar is visible before showing the pill (jumps otherwise) ...
                CATransaction.begin()
                self.navigationController?.setNavigationBarHidden(fullscreen, animated: true)
                CATransaction.setCompletionBlock {
                    UIView.animate(withDuration: 0.25) { [weak self] in
                        self?.panel?.view.alpha = 1.0
                        self?.pill?.view.alpha = 1.0
                        self?.view.backgroundColor = theme.galleryBackgroundColor
                    }
                }
                CATransaction.commit()
            }

        } else {
            if value {
                self.panel?.view.alpha = 0.0
                self.pill?.view.alpha = 0.0
                self.view.backgroundColor = theme.galleryHiddenNavigationBackgroundColor
                self.panel?.configuration.mode = .compact
            } else {
                self.panel?.view.alpha = 1.0
                self.pill?.view.alpha = 1.0
                self.view.backgroundColor = theme.galleryBackgroundColor
            }
        }

    }
}

// MARK: - GalleryImageViewType

extension GalleryImageViewController: GalleryImageViewType {

    func setIsLoading(_ isLoading: Bool) {
        activityIndicatorView.setAnimating(isLoading)
    }

    func showError(_ error: PresentableMessageType, actions: [MessageAction]) {
        errorPresenter.present(error, actions: actions)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }

    func setExternalAdditions(_ externalAdditions: [ExternalAddition], hasOverlay: Bool) {

        var buttons = [PillToolbarButton]()

        if hasOverlay {
            let button = GalleryImageToolbarDatasource.button(title: L10n.Gallery.Pill.Feature.Title.overlay, image: Asset.Icon.layers.image)
            button.handler = { [weak self] in self?.presenter.toggleImageOverlay() }
            buttons.append(button)
        }

        for externalAddition in externalAdditions {
            let button = GalleryImageToolbarDatasource.button(for: externalAddition)
            button.handler = { [weak self] in self?.presenter.navigate(to: externalAddition) }
            buttons.append(button)
        }

        pill?.view.isHidden = buttons.isEmpty
        pill?.toolbar.buttons = buttons
    }
}
