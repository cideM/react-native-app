//
//  PillToolbarButton.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 24.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import DesignSystem

final class PillToolbarButton: UIControl {

    var isMomentary = false
    var handler: (() -> Void)?

    override var isSelected: Bool { didSet { setNeedsDisplay() } }

    private let margin = 8.0
    private let imageWidthAndHeight = 24.0

    private let title: String
    private let image: UIImage

    // MARK: - Init

    required init(title: String = "", image: UIImage) {
        self.title = title
        self.image = image
        super.init(frame: .zero)
        isOpaque = false
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame: CGRect) has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Template methods

extension PillToolbarButton {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isMomentary { isSelected = false }
        handler?()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Drawing is done manually here because of layout problems we had in earlier versions
        // of this component (and wrong assumtions based on that)
        // Usually you would do all this with views, however:
        // the code was not refactored for views after solving mentioned layout problems
        // because it seems simple enough to maintain (its likely even simpler this way)

        let origin = CGPoint(x: (bounds.width - imageWidthAndHeight) / 2.0, y: margin)
        let size = CGSize(width: imageWidthAndHeight, height: imageWidthAndHeight)
        let frame = CGRect(origin: origin, size: size)

        if isSelected {
            UIColor.iconAccent.setFill()
            let dxdy = -4.0
            UIBezierPath(ovalIn: frame.insetBy(dx: dxdy, dy: dxdy)).fill()
        }

        image
            .withTintColor(isSelected ? .iconOnAccent : .iconTertiary)
            .withRenderingMode(.alwaysTemplate)
            .draw(in: frame)

        let title = Self.attributedTitle(with: title, isSelected: isSelected)
        let titleOrigin = CGPoint(x: (bounds.width - title.size().width) / 2.0,
                                  y: (origin.y + size.height + margin / 2.0))

        // Important to draw the text in a rect and not at a point
        // Text alignment is not considered when using title.draw(at: CGPoint)
        title.draw(in: .init(origin: titleOrigin, size: title.size()))
    }
}

// MARK: - Helpers

extension PillToolbarButton {

    static func attributedTitle(with string: String, isSelected: Bool) -> NSAttributedString {
        if isSelected {
            return .attributedString(
                with: string,
                style: .paragraphExtraSmallBold,
                decorations: [.color(.textAccent), .alignment(.center)])
        }
        return .attributedString(
            with: string,
            style: .paragraphExtraSmallBold,
            decorations: [.color(.textTertiary)])
    }

    func preferredContentHeight() -> CGFloat {
        margin + imageWidthAndHeight + margin + PillToolbarButton.attributedTitle(with: title, isSelected: false).size().height + margin
    }
}
