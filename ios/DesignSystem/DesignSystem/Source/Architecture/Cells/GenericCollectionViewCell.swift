//
//  GenericCollectionViewCell.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.10.23.
//

import Foundation
import UIKit

public class GenericCollectionViewCell<ContainedView: UIView>: UICollectionViewCell {

    public let view = ContainedView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .clear
        contentView.addSubview(view)

        view.pin(to: contentView)
    }
}
