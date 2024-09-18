//
//  ZoomableImageView.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

public final class ZoomableImageView: UIScrollView {

    private weak var externalDelegate: UIScrollViewDelegate?

    private var previousBoundsSize: CGSize = .zero
    private var previousContentOffset: CGPoint = .zero

    override public var contentOffset: CGPoint {
        didSet {
            centerScrollViewContent()
        }
    }

    override public var delegate: UIScrollViewDelegate? {
        get {
            externalDelegate
        }
        set {
            externalDelegate = newValue
        }
    }

    public var image: UIImage? {
        get {
            imageView.image
        }
        set {
            guard let newValue = newValue else { imageView.image = nil; return }
            let hadNoImageBefore = imageView.image == nil
            imageView.image = newValue
            layoutIfNeeded()
            // If the new image is exavtly the same size its likely an overlay
            // Hence keep the zoom scale to not throw the user off ...
            if hadNoImageBefore || image?.size != newValue.size {
                zoomScale = minimumZoomScale
            }
        }
    }

    public lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        recognizer.numberOfTapsRequired = 2
        return recognizer
    }()

    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()

    public init(image: UIImage? = nil) {
        super.init(frame: .zero)

        previousBoundsSize = bounds.size
        previousContentOffset = contentOffset

        super.delegate = self

        imageView.image = image

        addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        addGestureRecognizer(doubleTapGestureRecognizer)

        contentInsetAdjustmentBehavior = .never
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let image = imageView.image {
            minimumZoomScale = min(frame.size.width / image.size.width, frame.size.height / image.size.height)
            maximumZoomScale = minimumZoomScale * 6.0
        }

        if previousBoundsSize != bounds.size {
            if minimumZoomScale > zoomScale {
                zoomScale = minimumZoomScale
            }
            adjustContentOffset()
        }

        previousContentOffset = contentOffset
        centerScrollViewContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didDoubleTapImage(_ gestureRecognizer: UIGestureRecognizer) {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: imageView)
            let zoomRect = zoomRectForScale(1.0, center: center) // When the user double taps the photo we zoom in to the maximum scale that won't pixelate the image, which is 1.0.
            zoom(to: zoomRect, animated: true)
        }
    }

    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = .zero

        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width = frame.size.width / scale

        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        return zoomRect
    }

    private func viewForZooming() -> UIView? {
        subviews.first
    }

    private func adjustContentOffset() {
        defer {
            previousBoundsSize = bounds.size
        }
        let prevCenterPoint = CGPoint(x: (previousContentOffset.x + round(previousBoundsSize.width / 2) - imageView.frame.origin.x) / zoomScale,
                                      y: (previousContentOffset.y + round(previousBoundsSize.height / 2) - imageView.frame.origin.y) / zoomScale)

        if contentSize.width > bounds.size.width {
            imageView.frame.origin.x = 0
            contentOffset.x = prevCenterPoint.x * zoomScale - round(bounds.size.width / 2)
            if contentOffset.x < 0 {
                contentOffset.x = 0
            } else if contentOffset.x > contentSize.width - bounds.width {
                contentOffset.x = contentSize.width - bounds.width
            }
        }

        if contentSize.height > bounds.height {
            imageView.frame.origin.y = 0
            contentOffset.y = prevCenterPoint.y * zoomScale - round(bounds.height) / 2
            if contentOffset.y < 0 {
                contentOffset.y = 0
            } else if contentOffset.y > contentSize.height - bounds.height {
                contentOffset.y = contentSize.height - bounds.height
            }
        }
    }

    private func centerScrollViewContent() {
        var frame = imageView.frame
        if contentSize.width < bounds.width {
            frame.origin.x = CGFloat(roundf(Float((bounds.width - contentSize.width) / 2.0)))
        } else {
            frame.origin.x = 0
        }

        if contentSize.height < bounds.height {
            frame.origin.y = CGFloat(roundf(Float((bounds.height - contentSize.height) / 2.0)))
        } else {
            frame.origin.y = 0
        }

        imageView.frame = frame
    }
}

extension ZoomableImageView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        externalDelegate?.viewForZooming?(in: scrollView) ?? imageView
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        externalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        externalDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        externalDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        externalDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        externalDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        externalDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
