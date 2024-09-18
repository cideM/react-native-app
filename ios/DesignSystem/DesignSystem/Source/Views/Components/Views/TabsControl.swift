//
//  TabsControl.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 30.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

public final class TabsControl: UIView {

    public static let defaultHeight = 48.0

    public var showsDivider: Bool = false {
        didSet {
            divider.alpha = showsDivider ? 1 : 0
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Spacing.m * 2
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var selectionIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = underlineColor
        return view
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .borderSecondary
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.alpha = 0
        return view
    }()

    private var actions: [Action]? {
        didSet {
            setupSegments()
        }
    }

    public private(set) var selectedSegmentIndex: Int?

    public var underlineColor: UIColor = .textAccent {
        didSet {
            selectionIndicatorView.backgroundColor = underlineColor
        }
    }
    public var normalTextAttributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textSecondary)]) {
        didSet {
            stackView.arrangedSubviews.forEach { button in
                guard let button = button as? UIButton, let title = button.title(for: .normal) else { return }
                button.setAttributedTitle(NSAttributedString(string: title, attributes: normalTextAttributes), for: .normal)
            }
        }
    }
    public var highlightedTextAttributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textAccent)]) {
        didSet {
            stackView.arrangedSubviews.forEach { button in
                guard let button = button as? UIButton, let title = button.title(for: .selected) else { return }
                button.setAttributedTitle(NSAttributedString(string: title, attributes: highlightedTextAttributes), for: .selected)
            }
        }
    }

    public var disabledTextAttributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.secondaryLabel)]) {
        didSet {
            stackView.arrangedSubviews.forEach { button in
                guard let button = button as? UIButton, let title = button.title(for: .disabled) else { return }
                button.setAttributedTitle(NSAttributedString(string: title, attributes: disabledTextAttributes), for: .disabled)
            }
        }
    }

    private var selectionIndicatorViewLeadingAnchor: NSLayoutConstraint?
    private var selectionIndicatorViewWidthAnchor: NSLayoutConstraint?

    // MARK: - Init

    public init(frame: CGRect = .zero, actions: [Action]? = nil) {
        self.actions = actions

        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        clipsToBounds = true

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 7)
        ])

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor)
        ])

        setupSelectionIndicator()
        setupSegments()

        addSubview(divider)
        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: divider.trailingAnchor),
            selectionIndicatorView.bottomAnchor.constraint(equalTo: divider.topAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Template methods

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let selectedIndex = selectedSegmentIndex {
            selectSegment(at: selectedIndex)
        } else if !stackView.arrangedSubviews.isEmpty {
            selectSegment(at: 0, isAnimated: false)
        }
    }

    // MARK: - Setters

    public func setActions(_ actions: [Action]) {
        self.actions = actions

        if let selectedSegmentIndex = selectedSegmentIndex, selectedSegmentIndex < actions.count {
            highlightItem(at: selectedSegmentIndex, isAnimated: false)
        }
    }

    public func selectSegment(at index: Int, isAnimated: Bool = true) {
        guard let actions = actions, index < actions.count, index != selectedSegmentIndex else { return }

        selectedSegmentIndex = index
        updateSelectionIndicatorWidth(width: stackView.arrangedSubviews[selectedSegmentIndex ?? 0].frame.width)
        highlightItem(at: index, isAnimated: isAnimated)
    }

    public func disableSegement(at index: Int) {
        guard let actions, index < actions.count else { return }
        self.actions = actions.enumerated().map { _index, action in
            Action(title: action.title,
                   isEnabled: _index == index ? false : action.isEnabled,
                   handler: action.handler)
        }
    }

    // MARK: - Private helpers

    private func highlightItem(at index: Int, isAnimated: Bool) {
        stackView.arrangedSubviews.forEach { ($0 as? UIButton)?.isSelected = false }
        (stackView.arrangedSubviews[index] as? UIButton)?.isSelected = true

        underlineItem(at: index, isAnimated: isAnimated)
    }

    private func underlineItem(at index: Int, isAnimated: Bool) {
        let view = stackView.arrangedSubviews[index]

        selectionIndicatorViewLeadingAnchor?.constant = view.frame.minX - Spacing.m
        if isAnimated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func setupSegments() {
        guard let actions = actions else { return }

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for action in actions {
            let button = UIButton()
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            button.isEnabled = action.isEnabled

            // WORKAROUNDD:
            // Text is vertically off center although, reason unclear
            // Nudging text up a bit fixes this ...
            button.titleEdgeInsets.bottom = 10

            button.isAccessibilityElement = true
            button.setAttributedTitle(NSAttributedString(string: action.title.string, attributes: normalTextAttributes), for: .normal)
            button.setAttributedTitle(NSAttributedString(string: action.title.string, attributes: highlightedTextAttributes), for: .selected)
            button.setAttributedTitle(NSAttributedString(string: action.title.string, attributes: disabledTextAttributes), for: .disabled)

            button.titleLabel?.baselineAdjustment = .alignCenters
            button.addTarget(self, action: #selector(segmentTapped), for: .touchUpInside)
            button.sizeToFit()

            stackView.addArrangedSubview(button)
        }

        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }

    @objc private func segmentTapped(sender: UIButton) {
        guard let selectedSegmentIndex = stackView.arrangedSubviews.firstIndex(of: sender), selectedSegmentIndex != self.selectedSegmentIndex else { return }

        selectSegment(at: selectedSegmentIndex)
        actions?[selectedSegmentIndex].handler(selectedSegmentIndex)
    }

    private func setupSelectionIndicator() {
        addSubview(selectionIndicatorView)
        selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        let selectionIndicatorViewLeadingAnchor = selectionIndicatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        let selectionIndicatorViewWidthAnchor = selectionIndicatorView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            selectionIndicatorViewLeadingAnchor,
            selectionIndicatorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            selectionIndicatorViewWidthAnchor,
            selectionIndicatorView.heightAnchor.constraint(equalToConstant: 3)
        ])
        self.selectionIndicatorViewLeadingAnchor = selectionIndicatorViewLeadingAnchor
        self.selectionIndicatorViewWidthAnchor = selectionIndicatorViewWidthAnchor
    }

    private func updateSelectionIndicatorWidth(width: CGFloat) {
        selectionIndicatorViewWidthAnchor?.constant = width + Spacing.m * 2
    }
}

public extension TabsControl {
    struct Action {
        let title: NSAttributedString
        let handler: (Int) -> Void
        let isEnabled: Bool

        public init(title: NSAttributedString, isEnabled: Bool = true, handler: @escaping (Int) -> Void) {
            self.title = title
            self.handler = handler
            self.isEnabled = isEnabled
        }
    }
}
