//
//  PharmaAgentTableViewCell.swift
//  Knowledge
//
//  Created by Silvio Bulla on 05.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import DesignSystem

final class PharmaSubstanceCell: UICollectionViewCell {
    private lazy var drugsButton: SecondaryButton = {
        let view = SecondaryButton(mode: .onPrimaryBackgroundColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.iconType = .list
        view.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.otherPreparationsTapped()
        }), for: .touchUpInside)
        return view
    }()

    weak var delegate: PharmaSubstanceCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func configure(_ agentHeaderViewData: PharmaSubstanceSectionViewData) {
        drugsButton.title = agentHeaderViewData.commercialDrugsButtonTitle
        drugsButton.isEnabled = agentHeaderViewData.canSwitchDrug
    }
}

extension PharmaSubstanceCell {

    func commonInit() {
        contentView.backgroundColor = .backgroundPrimary
        contentView.addSubview(drugsButton)
        drugsButton.pin(
            to: contentView,
            insets: .init(
                top: Spacing.m,
                left: Spacing.m,
                bottom: 0,
                right: Spacing.m)
        )
    }
}
