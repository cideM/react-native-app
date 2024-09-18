//
//  SnippetViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import DesignSystem

/// @mockable
protocol SnippetViewType: AnyObject {
    func setViewData(_ snippet: Snippet, for deeplink: Deeplink)
}

final class SnippetViewController: UIViewController, StoryboardIdentifiable, SnippetViewType {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var synonymsEtymologyStackView: UIStackView!
    @IBOutlet private weak var synonymLabel: UILabel!
    @IBOutlet private weak var etymologyLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var targetsStackView: UIStackView!
    @IBOutlet private weak var scrollViewTopContraint: NSLayoutConstraint!

    private var presenter: SnippetPresenterType! // swiftlint:disable:this implicitly_unwrapped_optional

    static func viewController(with presenter: SnippetPresenterType) -> SnippetViewController {
        let storyboard = UIStoryboard(name: "SnippetStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: storyboardIdentifier) as! SnippetViewController // swiftlint:disable:this force_cast
        viewController.presenter = presenter
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarStyle()
        presenter.view = self

        view.backgroundColor = .backgroundPrimary
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let newHeight = round(stackView.frame.height + scrollViewTopContraint.constant + view.layoutMargins.top + view.layoutMargins.bottom)
        preferredContentSize = CGSize(width: AppConfiguration.shared.popoverWidth, height: newHeight)
    }

    func setViewData(_ snippet: Snippet, for deeplink: Deeplink) {
        title = snippet.title

        let synonymsText = snippet.synonyms.joined(separator: ", ")
        if !synonymsText.isEmpty {
            synonymLabel.attributedText = .attributedString(
                with: synonymsText,
                style: .paragraph,
                decorations: [.color(.textTertiary)]
            )
        } else {
            synonymLabel.isHidden = true
        }

        if let etymology = snippet.etymology, !etymology.isEmpty {
            etymologyLabel.attributedText = .attributedString(
                with: etymology,
                style: .paragraphSmall,
                decorations: [.italic, .color(.textTertiary)]
            )
        } else {
            etymologyLabel.isHidden = true
        }

        synonymsEtymologyStackView.isHidden = synonymLabel.isHidden && etymologyLabel.isHidden

        if let description = snippet.description {
            descriptionLabel.attributedText = .attributedString(with: description, style: .paragraph)
        } else {
            descriptionLabel.isHidden = true
        }

        // Remove the placeholder view that we have in Storyboard to keep things intact
        targetsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for destination in snippet.destinations {
            addLinkSeparator()
            addPopoverLinkView(for: destination, deeplink: deeplink)
        }
    }

    private func addLinkSeparator() {
        let separator = UIView()
        separator.backgroundColor = .separator

        targetsStackView.addArrangedSubview(separator)

        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.leftAnchor.constraint(equalTo: targetsStackView.leftAnchor),
            separator.rightAnchor.constraint(equalTo: targetsStackView.rightAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func addPopoverLinkView(for destination: SnippetDestination, deeplink: Deeplink) {
        let button = createPopoverLinkView(for: destination, deeplink: deeplink)
        targetsStackView.addArrangedSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: targetsStackView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: targetsStackView.trailingAnchor)
        ])
    }

    private func createPopoverLinkView(for destination: SnippetDestination, deeplink: Deeplink) -> UIView {
        let button = PopoverLinkView(title: destination.label ?? "",
                                     image: Asset.learningCard.image) { [weak self] in
            switch deeplink {
            case .learningCard(let learningCardDeepLink):
                // The sourceAnchor parameter is only relevant when opening a snippet in a learning card
                self?.presenter.go(to: LearningCardDeeplink(learningCard: destination.articleEid, anchor: destination.anchor, particle: nil, sourceAnchor: learningCardDeepLink.sourceAnchor))
            default:
                // When opening a snippet from other sources (e.g. pharma or monographs) we only need destination related information
                self?.presenter.go(to: LearningCardDeeplink(learningCard: destination.articleEid, anchor: destination.anchor, particle: nil, sourceAnchor: nil))
            }
        }
        return button
    }

    private func setNavigationBarStyle() {
        guard let standardAppearance = navigationController?.navigationBar.standardAppearance else { return }

        standardAppearance.shadowColor = .clear
        standardAppearance.backgroundColor = .backgroundSecondary

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        navigationController?.navigationBar.compactAppearance = standardAppearance
    }
}
