//
//  PharmaFooterView.swift
//  Knowledge
//
//  Created by Silvio Bulla on 10.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

class PharmaPrescribingInfoCell: UICollectionViewCell {

    @IBOutlet private weak var pdfsStackView: UIStackView!
    @IBOutlet private weak var headerStackView: UIStackView!
    @IBOutlet private weak var pdfButtonsContainerStackView: UIStackView!
    @IBOutlet private weak var prescribingInformationSectionLabel: UILabel!
    @IBOutlet private weak var prescribingInformationSectionValueLabel: UILabel!
    @IBOutlet private weak var prescribingInformationStackView: UIStackView!
    @IBOutlet private weak var prescribingInformationLabel: UILabel!
    @IBOutlet private weak var prescribingInformationSubtitleLabel: UILabel!
    @IBOutlet private weak var prescribingInformationButton: BigButton!
    @IBOutlet private weak var patientPackageStackView: UIStackView!
    @IBOutlet private weak var patientPackageLabel: UILabel!
    @IBOutlet private weak var patientPackageSubtitleLabel: UILabel!
    @IBOutlet private weak var patientPackageButton: BigButton!

    private var prescribingInformationAction: (() -> Void)?
    private var patientPackageAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    func setData(_ data: PharmaPrescribingInfoViewData, prescribingInformationAction: (() -> Void)?, patientPackageAction: (() -> Void)?) {
        self.prescribingInformationAction = prescribingInformationAction
        self.patientPackageAction = patientPackageAction

        prescribingInformationSectionLabel.attributedText = data.prescribingInformationSectionTitle
        prescribingInformationSectionValueLabel.attributedText = data.prescribingInformationSectionValue

        prescribingInformationLabel.attributedText = data.prescribingInformationTitle
        prescribingInformationSubtitleLabel.attributedText = data.prescribingInformationSubtitle

        patientPackageLabel.attributedText = data.patientPackageTitle
        patientPackageSubtitleLabel.attributedText = data.patientPackageSubtitle

        prescribingInformationStackView.isHidden = data.prescribingInformationTitle == nil
        patientPackageStackView.isHidden = data.patientPackageTitle == nil
    }
}

extension PharmaPrescribingInfoCell {

    func commonInit() {

        // Make sure view outside safe area is always transparent ...
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        headerStackView.backgroundColor = .backgroundSecondary
        pdfsStackView.backgroundColor = .backgroundPrimary

        let externalLinkImage = Asset.externalLink.image.withRenderingMode(.alwaysTemplate)

        for button in [prescribingInformationButton, patientPackageButton].compactMap({ $0 }) {
            button.imageScaleMode = .none
            button.style = .linkWithBorders
            button.tintColor = .iconTertiary
            button.setImage(externalLinkImage, for: .normal)
            button.setTitleColor(ThemeManager.currentTheme.patientPackageButtonTintColor, for: .normal)
            button.titleLabel?.font = Font.bold.font(withSize: 12)
        }

        prescribingInformationButton.setTitle(L10n.Substance.PrescribingInformationButton.title, for: .normal)
        prescribingInformationButton.addTarget(self, action: #selector(handlePrescribingInformationAction), for: .touchUpInside)

        patientPackageButton.setTitle(L10n.Substance.PrescribingInformationButton.title, for: .normal)
        patientPackageButton.addTarget(self, action: #selector(handlePatientPackageAction), for: .touchUpInside)
    }

    @objc func handlePrescribingInformationAction() {
        prescribingInformationAction?()
    }

    @objc func handlePatientPackageAction() {
        patientPackageAction?()
    }
}
