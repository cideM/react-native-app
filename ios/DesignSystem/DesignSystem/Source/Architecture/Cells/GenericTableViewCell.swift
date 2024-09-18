//
//  GenericTableViewCell.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 17.10.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class GenericTableViewCell<ContainedView: UIView>: UITableViewCell {

    public let view = ContainedView()

    override public init( style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(view)
        pinnedConstraints = view.pin(to: contentView)
    }

    // Insets Update Handling
    // Used for Design System Preview Purposes only! 
    // swiftlint:disable:next large_tuple
    private var pinnedConstraints: (top: NSLayoutConstraint,
                                 bottom: NSLayoutConstraint,
                                 leading: NSLayoutConstraint,
                                 trailing: NSLayoutConstraint)?

    public func updateInsets(_ insets: UIEdgeInsets) {
        pinnedConstraints?.top.constant = insets.top
        pinnedConstraints?.leading.constant = insets.left
        pinnedConstraints?.trailing.constant = insets.right
        pinnedConstraints?.bottom.constant = insets.bottom
    }
}
