//
//  DashboardSectionView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 16.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization
import DesignSystem

final class DashboardSectionView: UIStackView {

    enum Style {
        case list
        case cards
        case buttons
        case singleCard

        var hasShadow: Bool {
            switch self {
            case .list, .buttons: return true
            case .cards, .singleCard: return false
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .list, .buttons, .singleCard: return .clear
            case .cards: return ThemeManager.currentTheme.backgroundColor
            }
        }

        var mainCornerRadius: CGFloat {
            switch self {
            case .list: return ThemeManager.currentTheme.defaultCornerRadius
            case .cards, .buttons, .singleCard: return 0
            }
        }

        var itemCornerRadius: CGFloat {
            switch self {
            case .list, .singleCard: return 0
            case .cards, .buttons: return ThemeManager.currentTheme.defaultCornerRadius
            }
        }

        var itemSeparatorHeight: CGFloat {
            switch self {
            case .list: return 1
            case .cards, .buttons, .singleCard: return 12
            }
        }

        var itemSeparatorColor: UIColor {
            switch self {
            case .list: return .dividerSecondary
            case .cards, .buttons, .singleCard: return .clear
            }
        }

        var margins: NSDirectionalEdgeInsets {
            switch self {
            case .buttons: return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
            case .cards, .list, .singleCard: return .zero
            }
        }
    }

    private let sectionHeader: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let allButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let allButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: L10n.Dashboard.Sections.SectionHeader.all, attributes: ThemeManager.currentTheme.dashboardSectionHeaderButtonTitleAttributes), for: [])
            button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()

    private let arrowImageView: UIImageView = {
        let arrowImageView = UIImageView(image: Asset.Icon.disclosureArrow.image)
        arrowImageView.tintColor = ThemeManager.currentTheme.tabBarSelectedItemIconTintColor
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        return arrowImageView
    }()

    private let itemsShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let itemsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.clipsToBounds = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let minRowHeight: CGFloat = 62
    private var style: Style = .list
    static let contentCardsTagMultiple = 17 // random prime
    private weak var contentCardViewDelegate: ContentCardViewDelegate?
    private weak var linkCardViewDelegate: LinkCardViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        axis = .vertical
        spacing = 16
        addArrangedSubview(sectionHeader)
        addArrangedSubview(itemsShadowView)
        itemsShadowView.addSubview(itemsContainerView)
        itemsContainerView.constrain(to: itemsShadowView)

        itemsContainerView.addSubview(itemsStackView)
        itemsStackView.constrain(to: itemsContainerView)

        sectionHeader.addArrangedSubview(titleLabel)
        sectionHeader.addArrangedSubview(allButtonStackView)

        allButtonStackView.addArrangedSubview(allButton)
        allButtonStackView.addArrangedSubview(arrowImageView)

        arrowImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    }

    func configure(with section: DashboardSectionViewData,
                   style: Style,
                   contentCardViewDelegate: ContentCardViewDelegate?,
                   linkCardViewDelegate: LinkCardViewDelegate?
    ) {
        self.style = style
        self.contentCardViewDelegate = contentCardViewDelegate
        self.linkCardViewDelegate = linkCardViewDelegate
        // Style
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = style.margins
        itemsContainerView.backgroundColor = style.backgroundColor
        itemsContainerView.layer.cornerRadius = style.mainCornerRadius

        let hasConnerRadius = style.mainCornerRadius > 0
        itemsContainerView.layer.masksToBounds = hasConnerRadius

        if style.hasShadow {
            itemsShadowView.layer.shadowColor = ThemeManager.currentTheme.defaultShadowColor.cgColor
            itemsShadowView.layer.shadowRadius = ThemeManager.currentTheme.defaultShadowRadius
            itemsShadowView.layer.shadowOpacity = ThemeManager.currentTheme.defaultShadowOpacity
            itemsShadowView.layer.shadowOffset = ThemeManager.currentTheme.defaultShadowOffset
        }

        // Remove old views
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Set up button
        titleLabel.attributedText = NSAttributedString(string: section.title ?? "", attributes: .attributes(style: .h5, with: [.color(.textSecondary)]))
        allButtonStackView.isHidden = !section.hasAllButton
        allButton.touchUpInsideActionClosure = {
            section.tapAllClosure?()
        }

        self.sectionHeader.isHidden = !section.showsHeader

        // Add items
        for index in 0..<section.items.count {
            let item = section.items[index]
            let itemView = createItemView(for: item)
            itemsStackView.addArrangedSubview(itemView)

            if index < section.items.count - 1 {
                let separator = createSeparatorView()
                itemsStackView.addArrangedSubview(separator)
                separator.heightAnchor.constraint(equalToConstant: style.itemSeparatorHeight).isActive = true
            }
        }

    }

    private func createItemView(for item: DashboardSectionViewData.Item) -> UIView {
        var itemView: UIView
        switch item {
        case .text(let text):
            let view = DashboardTextItemView()
            view.configure(text: text)
            itemView = view
            itemView.layer.masksToBounds = true

        case .article(let articleItem):
            let view = LibraryTreeLearningCardView()
            view.configure(with: articleItem.learningCardMetaItem.title,
                           isFavorite: articleItem.isFavorite,
                           isLearned: articleItem.isLearned)
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.onTap = {
                articleItem.tapClosure(articleItem.learningCardMetaItem)
            }
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: minRowHeight).isActive = true
            view.addGestureRecognizer(gestureRecognizer)
            itemView = view

        case .clinicalTool(let clinicalToolItem):
            let view = DashboardClinicalToolItemView()
            view.configure(clinicalTool: clinicalToolItem.clinicalTool)

            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.onTap = {
                clinicalToolItem.tapClosure(clinicalToolItem.clinicalTool)
            }
            view.addGestureRecognizer(gestureRecognizer)
            itemView = view

        case .contentCard(let cardViewData):
            let contentCardView = ContentCardView()
            contentCardView.setup(with: cardViewData,
                                  delegate: contentCardViewDelegate)
            itemView = contentCardView
            itemView.tag = Self.contentCardsTagMultiple * (cardViewData.index + 1)

            #if DEBUG || QA
            let interaction = UIContextMenuInteraction(delegate: contentCardView)
            contentCardView.setInteractions(interactions: [interaction])
            #endif

        case .externalLink(let text, let url, let image):
            let view = LinkCardView()
            view.translatesAutoresizingMaskIntoConstraints = false
            let data = LinkCardView.ViewData(image: image, text: text, url: url)
            view.setup(with: data, delegate: linkCardViewDelegate)
            itemView = view
        }
        itemView.layer.masksToBounds = style.itemCornerRadius > 0
        itemView.layer.cornerRadius = style.itemCornerRadius

        return itemView
    }

    func createSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = style.itemSeparatorColor
        view.isOpaque = false
        return view
    }
}
