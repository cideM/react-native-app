//
//  SelectableDetailTableViewCell.swift
//  Common
//
//  Created by Manaf Alabd Alrahim on 24.11.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import DesignSystem

public class SelectableDetailTableViewCell: UITableViewCell {

    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Marked as public for testing purposes
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkImageView: UIImageView = {
        let image = Asset.check.image
            .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -12, bottom: 0, right: -12))
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .textAccent
        imageView.alpha = 0
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // Marked as public for testing purposes
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(mainView)
        let topLine = seperator()
        let bottomLine = seperator()
        let midSeperator = seperator()

        mainView.addSubview(topLine)
        mainView.addSubview(stackView)
        mainView.addSubview(bottomLine)

        stackView.addArrangedSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(checkImageView)

        stackView.addArrangedSubview(midSeperator)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),

            topLine.topAnchor.constraint(equalTo: mainView.topAnchor),
            topLine.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            bottomLine.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
            midSeperator.heightAnchor.constraint(equalToConstant: 0.5),

            checkImageView.widthAnchor.constraint(equalToConstant: 36)

        ])
    }

    public func set(title: String,
                    titleAttributes: [NSAttributedString.Key: Any] = ThemeManager.currentTheme.selectableCellTitleTextAttributes,
                    description: String? = nil,
                    descriptionAttributes: [NSAttributedString.Key: Any] = ThemeManager.currentTheme.selectableCellDescriptionTextAttributes) {
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: titleAttributes)

        if let description = description {
            descriptionLabel.attributedText = NSMutableAttributedString(string: description, attributes: descriptionAttributes)
        }
    }

    public func set(title: String, description: String? = nil) {

        titleLabel.attributedText = .attributedString(with: title,
                                                      style: .paragraphBold,
                                                      decorations: [.color(.textPrimary)])

        if let description = description {
            descriptionLabel.attributedText = .attributedString(with: description,
                                                          style: .paragraphSmall,
                                                          decorations: [.color(.textSecondary)])
            }
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.checkImageView.alpha = isSelected ? 1 : 0
    }

    private func seperator() -> UIView {
        let view = UIView()
        view.backgroundColor = .dividerPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
