//
//  GalleryViewController.swift
//  Knowledge
//
//  Created by CSH on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import UIKit

/// @mockable
protocol GalleryViewType: AnyObject {
    func setImagePresenters(_ presenters: [GalleryImageViewPresenterType])
    func goToImage(atIndex index: Int, animated: Bool)
}

final class GalleryViewController: UIPageViewController, GalleryViewType {

    private var imageGalleryDatasource: GalleryDatasource? {
        didSet {
            dataSource = imageGalleryDatasource
        }
    }
    private let presenter: GalleryPresenterType
    private var fullscreen = false {
        didSet {
            let theme = ThemeManager.currentTheme
            view.backgroundColor = fullscreen ? theme.galleryHiddenNavigationBackgroundColor : theme.galleryBackgroundColor
        }
    }

    init(presenter: GalleryPresenterType) {
        self.presenter = presenter
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 8])
        self.delegate = self
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        updateTitle()
        view.backgroundColor = ThemeManager.currentTheme.galleryBackgroundColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let viewController = viewControllers?.first as? GalleryImageViewController {
            prepare(viewController: viewController)
        }

        // Doing this in order to fade the "pill" toolbar while scrolling to the next page ...
        // Its important to only assign this in viewDidAppear() otherwise scrollViewDidScroll()
        // might be called with weird values and the pill toolbar is transparent sometimes
        view.firstScrollView()?.delegate = self
    }

    func setImagePresenters(_ presenters: [GalleryImageViewPresenterType]) {
        imageGalleryDatasource = GalleryDatasource(presenters: presenters)
    }

    func goToImage(atIndex index: Int, animated: Bool) {
        guard let dataSource = imageGalleryDatasource,
              let viewController = dataSource.viewController(at: index) else { return }

        if let currentViewController = viewControllers?.first,
            let currentIndex = dataSource.index(of: currentViewController) {
            if currentIndex < index {
                setViewControllers([viewController], direction: .forward, animated: animated, completion: nil)
            } else {
                setViewControllers([viewController], direction: .reverse, animated: animated, completion: nil)
            }
        } else {
            setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension GalleryViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // WORKAROUND:
        // There is no reliable way to track whats exactly visible and how much of it
        // Since UIPageViewController shuffles its "viewcontrollers" around at will
        // We`re reaching directly into the view hierarchy instead, fishing out what we need
        // This works well enough and bails out if unexpeced values are found ...
        let imageViewControllers = scrollView.subviews.compactMap { $0.subviews.first?.next as? GalleryImageViewController }
        guard !imageViewControllers.isEmpty else { return }

        // Calculate viewcontroller boundary intersections and derive from that
        // how much of each viewcontroller is visible ...
        let parentWidth = view.bounds.width
        let controllersAndFactors: [(GalleryImageViewController, CGFloat)] = imageViewControllers.map { viewController in
            let rect = viewController.view.convert(view.bounds, to: self.view)
            let intersection = rect.intersection(view.bounds)
            let size = intersection.size
            let factor = size.width / parentWidth
            return (viewController, 1.0 - factor)
        }

        // Use the visiblility "factor" to fancy up pill appearance ...
        for (viewController, factor) in controllersAndFactors {
            viewController.setPillVisibility(1.0 - factor)
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension GalleryViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateTitle()

        // WORKAROUND:
        // Can not override "viewController" property in order to set this
        // Hence its done here once the controllers come up
        // This is required in order to disable paging when the user is interacting
        // with the bottom sheet ...
        if let viewController = viewControllers?.first as? GalleryImageViewController {
            prepare(viewController: viewController)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        pendingViewControllers.forEach { viewController in
            if let viewController = viewController as? GalleryImageViewController {
                viewController.updateFullscreen(fullscreen)
            }
        }
    }

    private func updateTitle() {
        if let title = presenter.learningCardTitle, let index = viewControllers?.first?.title {
            self.title = "\(title)"

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.text = "(\(index))"
            label.textColor = .white
            let item = UIBarButtonItem(customView: label)
            navigationItem.setRightBarButton(item, animated: true)

        } else if let title = viewControllers?.first?.title {
            self.title = title
        } else {
            self.title = ""
        }
    }

    private func prepare(viewController: GalleryImageViewController) {
        viewController.presenter.delegate = self

        // WORKAROUND:
        // The galleries scrollview and bottom sheets (or: panel)  gesture recognizer setup interferes with iOS modal sheets
        // Dragging down the panel also attempts to dismiss the iOS modal sheet
        // Disabling "swipe to dismiss" for the iOS modal does not help, since its still moving when dragged
        // Modifying the gesture recognizer which is responsible for the dismissal seems to be the only way to fix this
        // Hence we're fishing out "_UISheetInteractionBackgroundDismissRecognizer" from the presentation controller
        // (in case this is a modal presentation) and hand it down to the gallery so it can temporarily disable it
        // when the user drags the panel around. This also has the benefit that the user can still dismiss the modal via swipe.
        let dismissalRecognizer = navigationController?.presentationController?.presentedView?.gestureRecognizers?.first
        viewController.presentationControllerDismissalRecognizer = dismissalRecognizer
    }
}

// MARK: - GalleryImageViewPresenterDelegate

extension GalleryViewController: GalleryImageViewPresenterDelegate {
    func didUpdateFullscreen(_ value: Bool) {
        self.fullscreen = value
    }

    func didUpdateDraggingState(isDragging: Bool) {
        // WORKAROUND:
        // There is no way to disable paging in UIPageViewController
        // Hence digging out the scrollview manually seems to be the only option ...
        // Disabling paging is important cause we want to scroll
        // inside a zoomed image view (which also is a scrollview)
        view.firstScrollView()?.isScrollEnabled = !isDragging
    }
}

// MARK: - Helpers

fileprivate extension UIView {

    func firstScrollView() -> UIScrollView? {
        for subview in subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            } else {
                return firstScrollView()
            }
        }
        return nil
    }
}
