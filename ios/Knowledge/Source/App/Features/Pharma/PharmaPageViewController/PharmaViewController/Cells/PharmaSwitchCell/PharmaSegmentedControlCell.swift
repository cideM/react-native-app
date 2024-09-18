//
//  PharmaSegmentedControlCell.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 05.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization
import DesignSystem

protocol PharmaSegmentedControlCellDelegate: AnyObject {
    func didSelect(anchor: String)
}

class PharmaSegmentedControlCell: UICollectionViewCell {

    struct PharmaSegmentedControlCellConfig {
        let title: String
        let anchor: String
        let isEmpty: Bool
        let isSelected: Bool
    }

    weak var delegate: PharmaSegmentedControlCellDelegate?

    private lazy var segmentedControl = AmbossSegmentedControl()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    // MARK: - Setters

    func setSegments(_ segments: [PharmaSegmentedControlCellConfig]) {
        segmentedControl.removeAllSegments()

        var selectedIndex = 0
        for (index, config) in segments.enumerated() {
            let action = UIAction(title: config.title, identifier: .init(config.anchor), handler: { [weak self] action in
                // Delay this a bit to let the switch animation finish ...
                DispatchQueue.main.async {
                    self?.delegate?.didSelect(anchor: action.identifier.rawValue)
                }
            })
            segmentedControl.insertSegment(action: action, at: index, animated: false)
            segmentedControl.setEnabled(!config.isEmpty, forSegmentAt: index)

            if config.isSelected {
                selectedIndex = index
            }
        }

        segmentedControl.selectedSegmentIndex = selectedIndex
    }

    // MARK: - Private helpers

    private func commonInit() {
        self.contentView.backgroundColor = .backgroundPrimary
        self.contentView.addSubview(segmentedControl)
        self.setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.heightAnchor.constraint(equalToConstant: 47),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.m + 1),
            segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    }
}
