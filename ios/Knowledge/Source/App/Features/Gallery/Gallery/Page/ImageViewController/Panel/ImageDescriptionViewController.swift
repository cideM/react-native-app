//
//  File.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 07.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Aiolos
import Common
import UIKit

// PLEASE NOTE!
// This viewcontroller uses very manual old school frame based layout via viewDidLayoutSubviews()
// Since its supposed to be used inside a folding and floating panel its bounds vary A LOT
// The view might also shrink to a .zero frame in extreme cases
// This totally trashes constraints, even "low priotity" ones
// Autolayout tries to recover from this by breaking random constraints left and right
// which leads to interesting and surprising UI bugs and no way to recover from them
// Hence, here we are, calculating the frames manually ...

final class ImageDescriptionViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 0
        view.backgroundColor = .clear
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    private lazy var titleImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = Asset.Icon.chevronUp.image
        view.tintColor = ThemeManager.currentTheme.galleryButtonTintColor
        view.backgroundColor = .clear
        view.contentMode = .center
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 0
        view.backgroundColor = .clear
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    private lazy var copyrightLabel: LinkAwareLabel = {
        let view = LinkAwareLabel(frame: .zero)
        view.backgroundColor = .clear
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.isUserInteractionEnabled = true // <- important for taps to work!
        return view
    }()

    weak var scrollViewDelegate: UIScrollViewDelegate? {
        didSet {
            scrollView.delegate = scrollViewDelegate
        }
    }

    var chevronTapCallback: (() -> Void)?
    var linkTapCallback: ((URL) -> Void)? {
        didSet {
            copyrightLabel.linkTapCallback = linkTapCallback
        }
    }

    private let titleBarHeight = 64.0
    private let spacing = 8.0
    private let titleImageWidth = 24.0
    private let margin = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)

    // The title could wrap differently on changes of the panel width
    // This looks odd and slightly broken, hence we try to keep it constant
    // Once the panel appears this value will be set and used ...
    // (at least as long as the title still fits inside)
    private var titleLabelWidth: CGFloat?
}

// MARK: - Template methods

extension ImageDescriptionViewController {

    override func loadView() {
        self.view = UIView(frame: .zero)
        view.backgroundColor = .backgroundPrimary
        view.addSubview(titleLabel)
        view.addSubview(titleImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(copyrightLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var titleWidth = view.bounds.width - margin.right - margin.left - spacing - titleImageWidth
        if let titleLabelWidth = titleLabelWidth, titleLabelWidth < titleWidth {
            titleWidth = titleLabelWidth
        }
        titleLabel.frame = .init(x: margin.left, y: margin.top, width: titleWidth, height: titleBarHeight)

        titleImageView.frame = .init(x: view.bounds.width - titleImageWidth - margin.right,
                                     y: margin.top,
                                     width: titleImageWidth,
                                     height: titleBarHeight)

        let scrollViewTop = margin.top + titleLabel.bounds.height + spacing
        scrollView.frame = .init(x: margin.left,
                                 y: scrollViewTop,
                                 width: view.bounds.width - margin.left - margin.right,
                                 height: view.bounds.height - scrollViewTop)

        let usableWidth = view.bounds.width - margin.left - margin.right
        let descriptionSize = descriptionSize(for: usableWidth)

        descriptionLabel.frame = .init(origin: .zero, size: descriptionSize)
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.width

        let offsetY = descriptionLabel.attributedText?.length ?? 0 > 0 ? descriptionSize.height + spacing : 0.0
        copyrightLabel.preferredMaxLayoutWidth = copyrightLabel.bounds.width
        copyrightLabel.frame = .init(origin: .init(x: 0, y: offsetY), size: copyrightSize(for: usableWidth))

        scrollView.contentSize = .init(width: scrollView.bounds.width,
                                       height: contentHeight(for: scrollView.bounds.width))
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        // Give the content in the scrollview a bit of wiggle room for devices with a real home button
        // The "virtual home button" introduces quite a bit of spacing itself, hence no need for this
        if parent?.view.safeAreaInsets.bottom == 0 {
            scrollView.contentInset.bottom = 8
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleLabelWidth = titleLabel.bounds.width
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        titleLabelWidth = nil
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        titleLabelWidth = titleLabel.bounds.width
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // User tapped in titlebar -> callback
        if let location = touches.first?.location(in: self.view), location.y <= (titleBarHeight + margin.top) {
            chevronTapCallback?()
        }
    }
}

// MARK: - Getters

extension ImageDescriptionViewController {

    func titleAndContentHeight(for width: CGFloat) -> CGFloat {
        var height = titleHeight()

        let contentHeight = contentHeight(for: width)
        if contentHeight > 0 {
            height += contentHeight
        } else {
            height -= spacing
        }

        return height
    }

    func titleHeight() -> CGFloat {
        margin.top + titleBarHeight + spacing
    }

    func contentHeight(for width: CGFloat) -> CGFloat {
        var height = 0.0

        let descriptionHeight = descriptionSize(for: width).height
        if descriptionHeight > 0 {
            height += descriptionHeight
            height += spacing
        }

        let copyrightHeight = copyrightSize(for: width).height
        if copyrightHeight > 0 {
            height += copyrightHeight
            height += spacing
        }

        height += spacing
        return height
    }

    func isContentCompletelyVisible() -> Bool {
        // It can happen that everything fits on a collapsed panel: Example:
        // Only title + copyright + virtual home button -> see US:Diabetes -> first image in article
        let descriptionText = descriptionLabel.text ?? descriptionLabel.attributedText?.string ?? ""
        let copyrightText = copyrightLabel.text ?? copyrightLabel.attributedText?.string ?? ""
        let hasNoContent = (descriptionText.isEmpty && copyrightText.isEmpty)
        let isCompletelyVisible = hasNoContent || scrollView.bounds.height >= scrollView.contentSize.height
        return isCompletelyVisible
    }
}

// MARK: - Setters

extension ImageDescriptionViewController {

    func setChevronIsHidden(_ isHidden: Bool) {
        titleImageView.isHidden = isHidden
    }

    func setChevronRotation(range: CGFloat) { // -> 0...1
        // This is called often when dragging the panel and can choke the main thread
        // Which leads to stuttery panel motion and hickups everywhere else
        // RunLoop.main.perform() only runs the updates when there is enough time left
        // which should solve the stutter ...
        let degrees = 180 - range * 180.0
        RunLoop.main.perform { [weak self] in
            self?.titleImageView.transform = CGAffineTransform(rotationAngle: degrees * (.pi / 180))
        }
    }

    func setTitle(_ title: String) {
        titleLabel.attributedText = attributedString(from: title, attributes: ThemeManager.currentTheme.galleryImageTitleTextAttributes)
        view.setNeedsLayout()
    }

    func setDescription(_ description: String) {
        descriptionLabel.attributedText = attributedString(from: description, attributes: ThemeManager.currentTheme.galleryImageDescriptionTextAttributes)
        view.setNeedsLayout()
    }

    func setCopyrightDescription(_ description: String) {
        copyrightLabel.attributedText = attributedString(from: description, attributes: ThemeManager.currentTheme.galleryImageCopyrightTextAttributes, linkAttributes: ThemeManager.currentTheme.galleryImageCopyrightLinkTextAttributes)
        view.setNeedsLayout()
    }

    func setContentAlpha(_ alpha: CGFloat) {
        descriptionLabel.alpha = alpha
        copyrightLabel.alpha = alpha
    }

    func setBackgroundColor(_ color: UIColor) {
        // Disabled for the purpose of a nice transition in dark mode.
        // Needs to be discussed again how we handle this case.
//        view.backgroundColor = color
    }
}

// MARK: - Helpers

private extension ImageDescriptionViewController {

    func attributedString(from htmlString: String, attributes: [NSAttributedString.Key: Any], linkAttributes: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard
            let htmlData = htmlString.data(using: .utf8),
            let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        else {
            return nil
        }

        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))

        if let linkAttributes = linkAttributes {
            attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length)) { link, range, _ in
                if let link = link {
                    attributedString.addAttributes(linkAttributes, range: range)
                    // .links have a default rendering that can't be overridden with our foreground color
                    // replacing the .link with an .attachment enables us to style the link
                    attributedString.removeAttribute(.link, range: range)
                    attributedString.addAttribute(.attachment, value: link, range: range)
                }
            }
        }

        return attributedString
    }

    func descriptionSize(for width: CGFloat) -> CGSize {
        guard let attributedText = descriptionLabel.attributedText, attributedText.length > 0 else {
            return .zero
        }
        let size = CGSize(width: width - margin.left - margin.right, height: .greatestFiniteMagnitude)
        return  attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
    }

    func copyrightSize(for width: CGFloat) -> CGSize {
        guard let attributedText = copyrightLabel.attributedText, attributedText.length > 0 else {
            return .zero
        }
        let size = CGSize(width: width - margin.left - margin.right, height: .greatestFiniteMagnitude)
        return attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
    }
}
