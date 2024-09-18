//
//  SnippetTargetButton.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 13.04.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import DesignSystem

final class PopoverLinkView: UIView {

    static let defaultHeight: CGFloat = 36

    private let title: String

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.learningCard.image)
        imageView.tintColor = .iconTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 2
        return button
    }()

    init(title: String, image: UIImage, action: @escaping () -> Void) {
        self.title = title

        super.init(frame: .zero)
        backgroundColor = .clear

        addSubview(iconImageView)
        iconImageView.image = image.withRenderingMode(.alwaysTemplate)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])

        button.touchUpInsideActionClosure = action
        button.setAttributedTitle(createTitleAttributedString(), for: [])
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createTitleAttributedString() -> NSAttributedString {
        let title = NSMutableAttributedString(attributedString: .attributedString(with: title, style: .paragraph, decorations: [.color(.textSecondary)]))

        let stringToReplace = " → "
        var range = NSRange(location: 0, length: title.length)
        while range.location != NSNotFound {
            range = (title.string as NSString).range(of: stringToReplace, options: [], range: range)
            if range.location != NSNotFound {
                title.replaceCharacters(in: range, with: createTargetChevronImageAttributedString())
                range = NSRange(location: range.location + range.length, length: title.length - (range.location + range.length))
            }
        }

        return title
    }

    private func createTargetChevronImageAttributedString() -> NSAttributedString {
        guard let titleFont = button.titleLabel?.font else { return NSAttributedString(string: "", attributes: nil) }

        let chevronImageAttachment = NSTextAttachment()

        let iconImage = Asset.Icon.disclosureArrow.image
        chevronImageAttachment.bounds = CGRect(x: 0, y: (titleFont.capHeight - iconImage.size.height).rounded() / 2, width: iconImage.size.width, height: iconImage.size.height)
        chevronImageAttachment.image = Asset.Icon.disclosureArrow.image.withTintColor(.iconQuaternary, renderingMode: .alwaysTemplate)

        return NSAttributedString(attachment: chevronImageAttachment)
    }
}
