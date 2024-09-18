//
//  PricesAndPackagesViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 14.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol PriceAndPackageViewType: AnyObject {
    func load(data: [PriceAndPackage])
}

final class PricesAndPackagesViewController: UIViewController, PriceAndPackageViewType {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1

        label.attributedText = .attributedString(with: L10n.PricesAndPackageSizes.TableView.title, style: .h5Bold, decorations: [.color(.textPrimary)])

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.closeButton.image, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerPrimary
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.dividerPrimary.cgColor
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var AVPLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = .attributedString(with: L10n.PricesAndPackageSizes.AvpLabel.title, style: .paragraphExtraSmall, decorations: [.color(.textSecondary)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var KTPLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = .attributedString(with: L10n.PricesAndPackageSizes.KtpLabel.title, style: .paragraphExtraSmall, decorations: [.color(.textSecondary)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var UVPLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = .attributedString(with: L10n.PricesAndPackageSizes.UvpLabel.title, style: .paragraphExtraSmall, decorations: [.color(.textSecondary)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let explanationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let presenter: PricesAndPackagesPresenterType

    init(presenter: PricesAndPackagesPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        view.backgroundColor = .backgroundPrimary
        view.addSubview(scrollView)
        scrollView.addSubview(doneButton)
        scrollView.addSubview(titleLabel)
        backgroundView.addSubview(mainStackView)
        scrollView.addSubview(backgroundView)
        explanationStackView.addArrangedSubview(AVPLabel)
        explanationStackView.addArrangedSubview(KTPLabel)
        explanationStackView.addArrangedSubview(UVPLabel)
        scrollView.addSubview(explanationStackView)

        setupHeaderConstraints()
        setupStackViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // there is an issue with calculations here (happens on iPhone X Max but not on iPad)
        // these sizes can have decimal parts like .33333333333334 (happens for stackView.frame.height and for view.layoutMargins.bottom)
        // in that case the final calculation (sum) may have different last digit on every calculation
        // if that happens (new last digit is different than previous one) the assignment of preferredContentSize will trigger recalculation
        // which in turn will trigger viewDidLayoutSubviews of the same controller and it become an infinity loop
        // this is noticable by some rare bugs in UI like popover jump on disappear
        // it is also additional job on CPU which is undesirable
        // the only reason the app is not stuck with this recursion is because changes happening through notifications, so there is a tiny delay
        // between view updates
        let spacing = 72.0
        let newHeight = round(doneButton.frame.height + titleLabel.frame.height + mainStackView.frame.height + explanationStackView.frame.height + spacing + view.layoutMargins.top + view.layoutMargins.bottom)
        preferredContentSize = CGSize(width: view.frame.width, height: newHeight)
    }

    func load(data: [PriceAndPackage]) {
        // Create the table stack view.
        let packageTitleAttributedString: NSAttributedString = .attributedString(
            with: L10n.Substance.packageSizeTitle.uppercased(),
            style: .paragraphExtraSmallBold,
            decorations: [.color(.textSecondary)])

        let packageView = wrappedLabelWith(attributedText: packageTitleAttributedString, hasFixedWidth: false)
        let priceTitleAttributedString: NSAttributedString = .attributedString(
            with: L10n.Substance.packagePriceTitle.uppercased(),
            style: .paragraphExtraSmallBold,
            decorations: [.color(.textSecondary)])

        let priceView = wrappedLabelWith(attributedText: priceTitleAttributedString, hasFixedWidth: true)

        let rowStackView = UIStackView()
        rowStackView.distribution = .fillProportionally
        rowStackView.spacing = 1
        rowStackView.addArrangedSubview(packageView)
        rowStackView.addArrangedSubview(priceView)
        mainStackView.addArrangedSubview(rowStackView)

        for priceAndPackage in data {
            let packageAttributedString: NSAttributedString = .attributedString(
                with: priceAndPackage.packageSizeDescription,
                style: .paragraph,
                decorations: [.color(.textSecondary)])

            let packageView = wrappedLabelWith(attributedText: packageAttributedString, hasFixedWidth: false)

            let superscriptValue = priceAndPackage.hasSuperscript ? " ¹" : ""
            let priceAttributedString: NSAttributedString = .attributedString(
                with: priceAndPackage.priceDescription.isEmpty ? L10n.Substance.notAvailableLabel : priceAndPackage.priceDescription + superscriptValue,
                style: .paragraph,
                decorations: [.color(.textSecondary)])

            let priceView = wrappedLabelWith(attributedText: priceAttributedString, hasFixedWidth: true)

            let rowStackView = UIStackView()
            rowStackView.distribution = .fillProportionally
            rowStackView.spacing = 1
            rowStackView.addArrangedSubview(packageView)
            rowStackView.addArrangedSubview(priceView)
            mainStackView.addArrangedSubview(rowStackView)
        }

        // Check if the KTP or superscript label should be shown.
        if !data.contains(where: { $0.hasKTP }) {
            KTPLabel.isHidden = true
        }

        if !data.contains(where: { $0.hasSuperscript }) {
            UVPLabel.isHidden = true
        }
    }

    @objc func doneButtonTapped() {
        presenter.dismissView()
    }
}

extension PricesAndPackagesViewController {

    private func wrappedLabelWith(attributedText: NSAttributedString, hasFixedWidth: Bool) -> UIView {
        let label = UILabel()
        let backgroundView = UIView()
        backgroundView.addSubview(label)
        backgroundView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        backgroundView.widthAnchor.constraint(equalToConstant: 120).isActive = hasFixedWidth
        backgroundView.backgroundColor = .backgroundPrimary
        label.attributedText = attributedText
        label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -2).isActive = true
        label.constrainEdges(to: backgroundView)
        return backgroundView
    }

    private func setupHeaderConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            doneButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            doneButton.widthAnchor.constraint(equalToConstant: 24),
            doneButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func setupStackViewConstraints() {
        scrollView.constrainEdges(to: view.safeAreaLayoutGuide)
        mainStackView.constrainEdges(to: backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            backgroundView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backgroundView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            explanationStackView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            explanationStackView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            explanationStackView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 16),
            explanationStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }
}
