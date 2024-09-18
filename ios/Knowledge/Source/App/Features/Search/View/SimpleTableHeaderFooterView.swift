//
//  SimpleTableHeaderFooterView.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 05.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

class SimpleTableHeaderFooterView: UIView {

    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0

        let tapGestureRecoginzer = UITapGestureRecognizer(target: self, action: #selector(labelWasTapped))
        label.addGestureRecognizer(tapGestureRecoginzer)

        return label
    }()
    private var action: (() -> Void)?

    static var contentMargins: UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.constrainEdges(to: layoutMarginsGuide)

        layoutMargins = SimpleTableHeaderFooterView.contentMargins
    }

    convenience init(attributedText: NSAttributedString, action: (() -> Void)? = nil) {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 44)))
        label.attributedText = attributedText
        label.isUserInteractionEnabled = action != nil
        self.action = action
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func labelWasTapped() {
        action?()
    }
}
