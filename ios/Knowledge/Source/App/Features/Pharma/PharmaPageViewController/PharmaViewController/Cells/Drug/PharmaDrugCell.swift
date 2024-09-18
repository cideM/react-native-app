//
//  AgentHeaderView.swift
//  Knowledge
//
//  Created by Silvio Bulla on 05.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization
import DesignSystem

protocol PharmaDrugCellDelegate: AnyObject {
    func showAllPricesAndPackageSizes()
}

final class PharmaDrugCell: UICollectionViewCell {
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    @IBOutlet private weak var dosageFormsLabel: UILabel!
    @IBOutlet private weak var dosageFormsValueLabel: UILabel!
    @IBOutlet private weak var prescriptionsLabel: UILabel!
    @IBOutlet private weak var prescriptionsValueLabel: UILabel!
    @IBOutlet private weak var atcLabel: UILabel!
    @IBOutlet private weak var atcValueLabel: UILabel!

    @IBOutlet private weak var packageSizeTitleLabel: UILabel!
    @IBOutlet private weak var firstPackageSizeLabel: UILabel!
    @IBOutlet private weak var secondPackageSizeLabel: UILabel!
    @IBOutlet private weak var thirdPackageSizeLabel: UILabel!
    @IBOutlet private weak var priceTitleLabel: UILabel!
    @IBOutlet private weak var firstPriceLabel: UILabel!
    @IBOutlet private weak var secondPriceLabel: UILabel!
    @IBOutlet private weak var thirdPriceLabel: UILabel!
    @IBOutlet private weak var firstStackView: UIStackView!
    @IBOutlet private weak var secondStackView: UIStackView!
    @IBOutlet private weak var thirdStackView: UIStackView!
    @IBOutlet private weak var showAllButton: UIButton!
    @IBOutlet private weak var drugAttributesStackView: UIStackView!
    @IBOutlet private var separators: [UIView]!

    weak var delegate: PharmaDrugCellDelegate?
    private var pricesAndPackages: [PriceAndPackage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func configure(_ drugHeaderViewData: PharmaDrugSectionViewData) {
        titleLabel.attributedText = drugHeaderViewData.title
        subtitleLabel.attributedText = drugHeaderViewData.subtitle

        lastUpdateLabel.attributedText = drugHeaderViewData.lastUpdatedDate

        dosageFormsLabel.attributedText = drugHeaderViewData.dosageFormsTitle
        dosageFormsValueLabel.attributedText = drugHeaderViewData.dosageFormsValue

        prescriptionsLabel.attributedText = drugHeaderViewData.prescriptionsTitle
        prescriptionsValueLabel.attributedText = drugHeaderViewData.prescriptionsValue

        atcLabel.attributedText = drugHeaderViewData.activeIngredientGroupTitle
        atcValueLabel.attributedText = drugHeaderViewData.activeIngredientGroupValue

        packageSizeTitleLabel.attributedText = drugHeaderViewData.packageSizeTitle
        priceTitleLabel.attributedText = drugHeaderViewData.priceTitle

        pricesAndPackages = drugHeaderViewData.pricesAndPackages
        setupPricesAndPackagesView()
        layoutIfNeeded()
    }
}

extension PharmaDrugCell {

    func commonInit() {
        backgroundColor = .backgroundPrimary
        contentView.backgroundColor = .backgroundPrimary
        drugAttributesStackView.layer.borderColor = UIColor.dividerSecondary.cgColor
        drugAttributesStackView.layer.borderWidth = 1
        drugAttributesStackView.layer.cornerRadius = 8
        drugAttributesStackView.layer.masksToBounds = true
        separators.forEach { $0.backgroundColor = .dividerSecondary }
    }

    func setupPricesAndPackagesView() {

        let attributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmall, with: [.color(.textPrimary)])

        switch pricesAndPackages.count {
        case 0:
            firstPackageSizeLabel.attributedText = NSAttributedString(string: L10n.Substance.notAvailableLabel, attributes: attributes)
            firstPriceLabel.attributedText = NSAttributedString(string: L10n.Substance.notAvailableLabel, attributes: attributes)
            secondStackView.isHidden = true
            thirdStackView.isHidden = true
        case 1:
            secondStackView.isHidden = true
            thirdStackView.isHidden = true
        case 2:
            thirdStackView.isHidden = true
        default: break
        }

        let packageSizeLabelArray: [UILabel] = [firstPackageSizeLabel, secondPackageSizeLabel, thirdPackageSizeLabel]
        let priceLabelArray: [UILabel] = [firstPriceLabel, secondPriceLabel, thirdPriceLabel]
        for index in 0..<min(pricesAndPackages.count, 3) {
            packageSizeLabelArray[index].attributedText = NSAttributedString(string: pricesAndPackages[index].packageSizeDescription, attributes: attributes)
            priceLabelArray[index].attributedText = NSAttributedString(string: pricesAndPackages[index].priceDescription.isEmpty ? L10n.Substance.notAvailableLabel : pricesAndPackages[index].priceDescription, attributes: attributes)
        }

        showAllButton.isHidden = pricesAndPackages.count < 4
        setupShowAllButton()
    }

    func setupShowAllButton() {
        let buttonTitle = NSMutableAttributedString(string: L10n.Substance.ShowAllButton.title, attributes: ThemeManager.currentTheme.showAllButtonTitleTextAttributes)
        showAllButton.setAttributedTitle(buttonTitle, for: .normal)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            showAllButton.configuration = configuration
        } else {
            showAllButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        showAllButton.addTarget(self, action: #selector(handleShowAllButtonAction), for: .touchUpInside)
    }

    @objc func handleShowAllButtonAction() {
        delegate?.showAllPricesAndPackageSizes()
    }
}
