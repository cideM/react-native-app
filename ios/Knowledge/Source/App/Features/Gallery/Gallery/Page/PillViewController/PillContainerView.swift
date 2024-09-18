//
//  TouchPermeableView.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 21.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import UIKit

//   Screen
// | size    |
// +---------+- - - +    +- - - +---------+
// |       O |      |    |      | O       | <- UIScrollView
// |         |      |    |      |         | O -> Pill toolbar
// |         |      |    |      |         |
// |       O |      |    |      | O       |
// +---------+- - - +    +- - - +---------+
// |  Content size  |

// Reasons for existence of this class:
// * It lets all touches through except ones the happend on tagged views
//   (which in this case is the pill toolbar)
// * It makes it appear as if the pill toolbar snaps to screen corners
//   by placing it strategically in a srollview and fiddling with the paging
//   (see schema above)
final class PillContainerView: UIScrollView {

    var insets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)

    // Additional offset to nudge the pill around
    // Used for dismissal effects when swiping thorugh gallery screens
    var pillOffset: CGPoint = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    private(set) var pillPosition: PillPosition = .bottomRight
    private var initialPillPosition: PillPosition?

    private var pill: UIView
    private var lastBounds: CGRect?

    required init(pill: UIView) {
        self.pill = pill
        super.init(frame: .zero)
        addSubview(pill)
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setters

extension PillContainerView {

    func setInitialPillPosition(_ position: PillPosition) {
        initialPillPosition = position
    }
}

// MARK: - Template methods

extension PillContainerView {

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Only touches on the pill or its subviews are accepted
        // "Accepted" means:
        // * Scrollview only scrolls when dragging the pill
        // * Touch events are forwarded to the pills subviews
        // All touches outside the pill get proxied forward to the view below ...
        if let view = super.hitTest(point, with: event) {
            if isViewOrSubviewPill(view) {
                return view
            }
        }
        return nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        pill.frame.origin = .init(x: bounds.width - pill.bounds.width - insets.right + pillOffset.x,
                                  y: bounds.height - pill.bounds.height - insets.bottom + pillOffset.y)

        let overlapH = bounds.width - insets.left - insets.right - pill.bounds.width
        let overlapV = bounds.height - insets.top - insets.bottom - pill.bounds.height
        let width = bounds.width + overlapH
        let height = bounds.height + overlapV
        contentSize = .init(width: width, height: height)

        // When the container grows and the pill is not at the bottom
        // it "slips down" with the growing space. Below code avoids that.
        // You can test what this does by always "falsing" "didGrow"
        // and collapsing an expanded panel ...
        var didGrow = false
        if let lastBounds = lastBounds, lastBounds.height < bounds.height {
            didGrow = true
        }
        // ... we want the pill to slip down a little bit though in case the panel
        // has been extended far enough to push the pill out of the screens top bounds
        // If pillShouldNotSlip is always true the pill will jump when slowly collapsing
        // a panel that has previously pushed the pill out of the top screen border  ..
        let pillShouldNotSlip = bounds.height > pill.bounds.height + insets.top + insets.bottom

        if didGrow && pillShouldNotSlip {
            switch pillPosition {
            case .bottomLeft, .bottomRight: contentOffset.y = 0
            case .topLeft, .topRight: contentOffset.y = overlapV
            }
        }

        // This depends on the views bounds size hence we only want to do it
        // once it did arrive at its final dimension ...
        if bounds.size != .zero, let initialPillPosition = initialPillPosition {
            setContentOffset(contentOffset(for: initialPillPosition), animated: false)
            pillPosition = initialPillPosition
            self.initialPillPosition = nil
        }

        lastBounds = bounds
    }
}

// MARK: - UIScrollViewDelegate

extension PillContainerView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = calculatePosition()
        if isDragging, pillPosition != newPosition { pillPosition = newPosition }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pillPosition = calculatePosition()
    }
}

// MARK: - Helpers

private extension PillContainerView {

    func calculatePosition() -> PillPosition {
        let isMaxX = round(contentOffset.x + bounds.width) == contentSize.width
        let isMaxY = round(contentOffset.y + bounds.height) == contentSize.height
        return PillPosition(isMaxX: isMaxX, isMaxY: isMaxY)
    }

    func isViewOrSubviewPill(_ view: UIView) -> Bool {
        if view === pill {
            return true
        }

        var viewInFocus = view
        while let view = viewInFocus.superview {
            if view === self.pill {
                return true
            } else {
                viewInFocus = view
            }
        }

        return false
    }

    func contentOffset(for position: PillContainerView.PillPosition) -> CGPoint {
        var isMaxX, isMaxY: Bool
        switch position {
        case .topLeft:     isMaxX = true; isMaxY = true
        case .topRight:    isMaxX = false; isMaxY = true
        case .bottomLeft:  isMaxX = true; isMaxY = false
        case .bottomRight: isMaxX = false; isMaxY = false
        }

        return CGPoint(x: isMaxX ? bounds.width : 0, y: isMaxY ? bounds.height : 0)
    }
}
