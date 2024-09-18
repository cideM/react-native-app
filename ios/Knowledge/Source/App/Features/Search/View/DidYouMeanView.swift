//
//  DidYouMeanView.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 12.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

public final class DidYouMeanView: UIView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = true // required for tap recognizer
        return label
    }()

    public init(_ queryCallback: @escaping (String, String) -> Void) {
        callback = queryCallback
        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .vertical)
        backgroundColor = .backgroundPrimary
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        label.addGestureRecognizer(recognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let callback: ((String, String) -> Void)
    private var searchTerm: String?
    private var didYouMean: String?

    public func set(searchTerm: String, didYouMean: String) {
        self.searchTerm = searchTerm
        self.didYouMean = didYouMean

        let italic: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmall, with: [.italic, .color(.textTertiary)])
        let bold: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textTertiary)])
        let brandBold: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textAccent)])
        let brandBoldUnderline: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textAccent), .underline(.textAccent)])

        let titlePrefix = NSAttributedString(string: L10n.Search.Didyoumean.title, attributes: italic)
        let titleSuffix = NSAttributedString(string: didYouMean, attributes: bold)

        let title = NSMutableAttributedString(attributedString: titlePrefix)
        title.append(NSMutableAttributedString(string: " ", attributes: bold))
        title.append(titleSuffix)

        let subtitlePrefix = NSAttributedString(string: L10n.Search.Didyoumean.subtitle, attributes: bold)
        let subtitleSuffix = NSMutableAttributedString(string: " \"", attributes: brandBold)
        subtitleSuffix.append(NSMutableAttributedString(string: searchTerm, attributes: brandBoldUnderline))
        subtitleSuffix.append(NSMutableAttributedString(string: "\"", attributes: brandBold))

        let subtitle = NSMutableAttributedString(attributedString: subtitlePrefix)
        subtitle.append(NSMutableAttributedString(string: " "))
        subtitle.append(subtitleSuffix)

        let attributedText = NSMutableAttributedString(attributedString: title)
        attributedText.append(NSAttributedString(string: "\n"))
        attributedText.append(subtitle)
        attributedText.append(NSAttributedString(string: "?", attributes: bold))

        label.attributedText = attributedText
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let searchTerm = self.searchTerm, let didYouMean = self.didYouMean else {
            assertionFailure("SearchTerm and didYouMean should be set before displaying this view")
            return
        }
        callback(searchTerm, didYouMean)
    }
}
