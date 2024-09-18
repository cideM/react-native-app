//
//  SearchResultTableViewCell.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 09.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class SearchResultTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .backgroundPrimary
    }

    @IBOutlet private var tagButton: UIButton! {
        didSet {
            tagButton.isUserInteractionEnabled = false
            tagButton.layer.borderColor = ThemeManager.currentTheme.searchResultTableViewTagButtonOutlineColor.cgColor
            tagButton.layer.cornerRadius = 10
            tagButton.layer.borderWidth = 2
        }
    }
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var subtitleLabel: UILabel!
    @IBOutlet private(set) var bodyLabel: UILabel!

    private let titleStyle: HTMLParser.Attributes = {
        HTMLParser.Attributes(
            normal: ThemeManager.currentTheme.searchResultTableViewCellNormalTitleAttributes,
            bold: ThemeManager.currentTheme.searchResultTableViewCellBoldTitleAttributes,
            italic: ThemeManager.currentTheme.searchResultTableViewCellItalicTitleAttributes)
    }()

    private let subtitleStyle: HTMLParser.Attributes = {
        HTMLParser.Attributes(
            normal: ThemeManager.currentTheme.searchResultTableViewCellNormalSubtitleAttributes,
            bold: ThemeManager.currentTheme.searchResultTableViewCellBoldSubtitleAttributes,
            italic: ThemeManager.currentTheme.searchResultTableViewCellItalicSubtitleAttributes)
    }()

    private let bodyStyle: HTMLParser.Attributes = {
        HTMLParser.Attributes(
            normal: ThemeManager.currentTheme.searchResultTableViewCellNormalBodyAttributes,
            bold: ThemeManager.currentTheme.searchResultTableViewCellBoldBodyAttributes,
            italic: ThemeManager.currentTheme.searchResultTableViewCellItalicBodyAttributes)
    }()

    func configure(item: PharmaSearchViewItem) {
        tagButton.isHidden = true
        titleLabel.attributedText = try? HTMLParser.attributedStringFromHTML(htmlString: item.title, with: titleStyle)
        subtitleLabel.isHidden = true

        if let details = item.details {
            bodyLabel.attributedText = try? HTMLParser.attributedStringFromHTML(htmlString: details, with: bodyStyle)
            bodyLabel.isHidden = false
            bodyLabel.numberOfLines = 2
        } else {
            bodyLabel.isHidden = true
        }
    }

    func configure(item: MonographSearchViewItem) {
        tagButton.isHidden = true
        titleLabel.attributedText = item.title
        subtitleLabel.isHidden = true
        if let body = item.body {
            bodyLabel.attributedText = body
            bodyLabel.isHidden = false
            bodyLabel.numberOfLines = 2
        } else {
            bodyLabel.isHidden = true
        }
    }

    func configure(item: GuidelineSearchViewItem) {
        if let tag = item.tag {
            tagButton.isHidden = false
            tagButton.setAttributedTitle(NSMutableAttributedString(string: tag.uppercased(), attributes: ThemeManager.currentTheme.searchTagLabelTextAttributes), for: .normal)
        } else {
            tagButton.isHidden = true
        }

        titleLabel.attributedText = try? HTMLParser.attributedStringFromHTML(htmlString: item.title, with: titleStyle)
        subtitleLabel.isHidden = true

        if let details = item.details {
            bodyLabel.attributedText = try? HTMLParser.attributedStringFromHTML(htmlString: details, with: bodyStyle)
            bodyLabel.isHidden = false
            bodyLabel.numberOfLines = 0
        } else {
            bodyLabel.isHidden = true
        }
    }
}
