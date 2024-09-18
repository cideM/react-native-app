//
//  LearningCardToolbar.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

/// Purpose of this custom toolbar is to work around some shortcomings of UIToolbar
///
/// Features:
/// * Displays icons AND subtitles for them
/// * Displays a seperator
/// * Aligns some items to the right and some to the left border if the toolbar is wide
///
/// Usage:
/// * Initialise the toolbar and add item groups to it
/// * Item groups can contain any UIControl subclasses
/// * Two classes tailored to the toolbar are: "Button" and "Separator"
/// * Groups can be left or right aligned
/// * A special case is a "seperator" group which gets hidden on wide screens
///
/// Sample:
/// ```
/// let toolbar = LearningCardToolbar()
/// toolbar.addGroup(.leftAligned(items: [LearningCardToolbar.Button(image: UIImage(named: "myimage"), handler: { _ in })]))
/// toolbar.addGroup(.seperator(item: LearningCardToolbar.Separator(width: 16))
/// toolbar.addGroup(.rightAligned(items: [LearningCardToolbar.Button(image: UIImage(named: "myimage"), handler: { _ in })]))
/// ```
final class LearningCardToolbar: UIView {

    // MARK: - Public vars

    static let toolbarHeight: CGFloat = 54
    let maxElementWidth: CGFloat = 95

    // MARK: - Private vars

    private var groups = [ControlGroup]() {
        didSet {
            for view in container.subviews { view.removeFromSuperview() }
            setNeedsLayout()
        }
    }

    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let line: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .dividerPrimary
        return view
    }()

    private let background: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .canvas
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setters

    /// A control group is:
    /// * One or more controls
    /// * Either: aligned to the right or to the left
    /// * Or: A single control used as a seperator (that has no special alignment)
    func addGroup(_ group: ControlGroup) {
        switch group {
        case .leftAligned:
            groups.append(group)
        case .rightAligned(let items):
            // Inversing this cause items get added from the rigth side ...
            groups.append(.rightAligned(items: items.reversed()))
        case .seperator:
            groups.append(group)
        }
    }

    // MARK: - Template methods

    override func layoutSubviews() {
        super.layoutSubviews()

        // Removes constraints added by the toolbar for distributing items ...
        let identifier = "toolbarConstraint"
        for control in groups.allControls {
            for constraint in container.constraints.reversed() where constraint.identifier == identifier {
                container.removeConstraint(constraint)
            }
            for constraint in control.constraints.reversed() where constraint.identifier == identifier {
                control.removeConstraint(constraint)
            }
        }

        let fixedWidthsTotal = groups.allControls
            .compactMap { $0.widthConstraintValue }
            .reduce(into: CGFloat(0)) { partialResult, widhtConstraintConstant in partialResult += widhtConstraintConstant }
        let dynamicWidthItems = groups.allControls.filter { $0.widthConstraintValue == nil }
        let dynamicWidthInBounds = (bounds.width - fixedWidthsTotal) / CGFloat(dynamicWidthItems.count)
        let dynamicWidthPerElement = min(maxElementWidth, dynamicWidthInBounds)

        // Add constraints to distribute items along toolbar width ...
        var xposLeft = CGFloat(0)
        var xposRight = bounds.width - dynamicWidthPerElement

        for group in groups {
            for control in group.controls {
                var xpos: CGFloat
                switch group {
                case .leftAligned:
                    xpos = xposLeft
                    container.addSubview(control)
                case .rightAligned:
                    xpos = xposRight
                    container.addSubview(control)
                case .seperator:
                    // Hide seperator once elements are being aligned to screen edges ...
                    if dynamicWidthInBounds > dynamicWidthPerElement {
                        continue
                    } else {
                        xpos = xposLeft
                        container.addSubview(control)
                    }
                }

                // Items is:
                // * either dynamic width based on availabel space and number of eitems
                // * or a fixed width as provided via constraint by the item itself
                let width = control.widthConstraintValue ?? dynamicWidthPerElement
                let leadingConstraint = control.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: xpos)
                let widthConstraint = control.widthAnchor.constraint(equalToConstant: width)
                let topConstraint = control.topAnchor.constraint(equalTo: container.topAnchor)
                let bottomConstraint = control.bottomAnchor.constraint(equalTo: container.bottomAnchor)

                // Adding an identifier here in order to easily remove what we did here when relayouting ...
                [leadingConstraint, widthConstraint, topConstraint, bottomConstraint].forEach {
                    $0.identifier = identifier
                    $0.isActive = true
                }

                switch group {
                case .leftAligned, .seperator: xposLeft += width
                case .rightAligned: xposRight -= width
                }
            }
        }
    }
}

private extension LearningCardToolbar {

    func commonInit() {
        addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.topAnchor.constraint(equalTo: topAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])

        addSubview(background)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.topAnchor.constraint(equalTo: line.bottomAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
}

// MARK: - Helpers

extension LearningCardToolbar {

    enum ControlGroup {
        case leftAligned(items: [UIControl])
        case rightAligned(items: [UIControl])
        case seperator(item: UIControl)

        var controls: [UIControl] {
            switch self {
            case .leftAligned(let items): return items
            case .rightAligned(let items): return items
            case .seperator(let item): return [item]
            }
        }
    }
}

fileprivate extension Array where Element == LearningCardToolbar.ControlGroup {

    var allControls: [UIControl] {
        var all = [UIControl]()
        for element in self {
            switch element {
            case .leftAligned(let items), .rightAligned(let items):
                all.append(contentsOf: items)
            case .seperator(let item):
                all.append(item)
            }
        }
        return all
    }
}

fileprivate extension UIView {

    var widthConstraintValue: CGFloat? {
        constraints.first { $0.firstAttribute == .width }?.constant
    }
}
