//
//  PillToolbarView.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 24.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

final class PillToolbarView: UIView {

    static let preferredSize: CGSize = .init(width: 53, height: 142)

    var buttons: [PillToolbarButton] = [] {
        didSet {
            for subview in subviews {
                subview.removeFromSuperview()
            }
            for button in buttons {
                addSubview(button)
                button.addTarget(self, action: #selector(updateButtonStates(sender:)), for: .touchUpInside)
            }
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    @objc func updateButtonStates(sender: PillToolbarButton) {
        // Momentary buttons cant be selected or highlighted
        // They just trigger actions (ex: smart zoom modal)
        // Code after this guard is for updating the toolbar
        // Which is never needed for momentary buttons ...
        guard sender.isMomentary == false else { return }

        let toggleButtons = buttons.filter { $0.isMomentary == false }
        let selectedButtonDidChange = toggleButtons.first { $0.isSelected } !== sender
        guard selectedButtonDidChange else {
            // Toggle touched button if its the only one ...
            if toggleButtons.count == 1 {
                sender.isSelected.toggle()
            }
            return
        }
        // Deselect old, select touched button ...
        for button in buttons {
            button.isSelected = button === sender
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width / 2.0
        let margin = 8.0

        var posY = margin
        for button in buttons {
            let height = button.preferredContentHeight()
            button.bounds.size = .init(width: bounds.width, height: height)
            button.frame.origin = .init(x: 0, y: posY)
            posY += height
        }

        bounds.size.height = posY + margin
    }
}

private extension PillToolbarView {

    func commonInit() {
        layer.masksToBounds = false
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.borderSecondary.cgColor

        layer.shadowColor = UIColor.shadow.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 5.0

        backgroundColor = .backgroundPrimary
    }
}
