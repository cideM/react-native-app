//
//  PopoverContainerViewController.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 21.11.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class PopoverContainerViewController: UIViewController {

    private let backgroundColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        return view
    }()

    private let headerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        return view
    }()

    private let container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2 // in case title length is less than 2 lines it will automatically center cause autolayout is setup via centerY anchor
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    private let closeButton: UIButton = {
        let height = PopoverContainerViewController.headerHeight
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(Asset.Icon.crossSmall.image, for: .normal)
        view.contentMode = .center
        view.tintColor = .iconTertiary
        return view
    }()

    private var titleObservation: NSKeyValueObservation?
    private var bottomMargin: CGFloat = 12

    convenience init(child viewController: UIViewController) {
        self.init(nibName: nil, bundle: nil)
        addChild(viewController)
        viewController.willMove(toParent: self)
        container.addSubview(viewController.view)
        updateTitle(viewController.title)
        titleObservation = viewController.observe(\.title) { [weak self] viewController, _ in
            self?.updateTitle(viewController.title)
        }
    }
}

// MARK: Setters

extension PopoverContainerViewController {

    func updateBackground(isHidden: Bool) {
        headerView.alpha = isHidden ? 0.0 : 1.0
        backgroundColorView.alpha = isHidden ? 0.0 : 1.0
    }
}

// MARK: Template methods

extension PopoverContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.insertSubview(backgroundColorView, aboveSubview: view)
        backgroundColorView.pin(to: view, insets: .init(top: Self.headerHeight, left: 0.0, bottom: 0.0, right: 0.0))

        updateBackground(isHidden: false)
        setupHeader()

        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Self.headerHeight)
        ])

        // If the device has a "home button indictor" no bottom margin is needed
        // since the blank space around the indicator is perceived as margin
        if let bottomInset = UIApplication.keyWindow?.safeAreaInsets.bottom, bottomInset > 0 {
            bottomMargin = 0
        }

        view.addSubview(container)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bottomMargin),
            headerView.bottomAnchor.constraint(equalTo: container.topAnchor)
        ])

        guard let childViewController = children.first else { return }
        updatePreferredContentSize(with: childViewController.preferredContentSize)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let childViewController = children.first else { return }
        childViewController.view.frame = container.bounds
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard let childViewController = children.first else { return }
        updatePreferredContentSize(with: childViewController.preferredContentSize)
    }
}

// MARK: Helpers

private extension PopoverContainerViewController {

    static let headerHeight = CGFloat(56)

    func updateTitle(_ title: String?) {
        titleLabel.alpha = 0
        let title = title ?? ""
        let attributedText = NSAttributedString.attributedString(with: title, style: .h5)
        titleLabel.attributedText = attributedText
        UIView.animate(withDuration: 0.8) { [weak self] in self?.titleLabel.alpha = 1 }
    }

    func updatePreferredContentSize(with size: CGSize) {
        let height = size.height // height of the embedded viewcontroller
            + Self.headerHeight // the titlebar
            + (UIApplication.keyWindow?.safeAreaInsets.bottom ?? 0) // inset for the "home button indicator" (if any)
            + bottomMargin // additional margin that is only applied if the device does not have a "virtual home button"
        preferredContentSize = .init(width: size.width, height: height + 28)
    }

    func setupHeader() {
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            headerView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            headerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -24)
            // trailing anchor: see below -> close button
            // label has max 2 lines so no top and bottom anchor required
        ])

        headerView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: Self.headerHeight),
            closeButton.heightAnchor.constraint(equalToConstant: Self.headerHeight),
            headerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 0),
            closeButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor) // close button is much bigger than its image hence no padding required
        ])

        closeButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
