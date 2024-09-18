//
//  ContentCardFeedPresenter.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 18.10.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import DesignSystem
import BrazeKit
import UIKit

extension ContentCardView.ViewData: GenericListViewData {}

protocol ContentCardFeedPresenterType: GenericListViewPresenterType {
    func didTapContentCard(at index: Int)
}

class ContentCardFeedPresenter: ContentCardFeedPresenterType {
    typealias View = GenericListTableViewController<ContentCardFeedDataSource, ContentCardFeedPresenter>

    weak var view: (View)? {
        didSet {
            reloadView()
        }
    }

    private var cards: [BrazeContentCard]
    private var brazeApplicationService: BrazeApplicationServiceType
    init(cards: [BrazeContentCard],
         brazeApplicationService: BrazeApplicationServiceType = resolve()) {
        self.cards = cards
        self.brazeApplicationService = brazeApplicationService
    }

    func didTapContentCard(at index: Int) {
        let card = cards[index]
        #if DEBUG || QA
        // if contentCards is already selected by the user
        if let element = brazeApplicationService.forcedCards.enumerated().first(where: {
            $1.id == card.id
        }) {
            // handle deselection
            brazeApplicationService.forcedCards.remove(at: element.offset)
        } else {
            // handle selection
            if brazeApplicationService.forcedCards.count < BrazeApplicationService.maximumNumberOfDisplayedCards {
                brazeApplicationService.forcedCards.append(card)
            } else {
                // remove oldest element and append the newest
                var cards = brazeApplicationService.forcedCards
                cards.removeFirst()
                cards.append(card)
                brazeApplicationService.forcedCards = cards
            }
        }
        reloadView()
        #endif
    }

    func reloadView() {
        let data = map(cards: cards)
        view?.update(with: data)
    }

    private func map(cards: [BrazeContentCard]) -> [ContentCardView.ViewData] {
        var items: [ContentCardView.ViewData] = []
        for (index, card) in cards.enumerated() {
            var isSelected = false
            #if DEBUG || QA
            isSelected = brazeApplicationService.forcedCards.contains(where: { $0.id == card.id })
            #endif
            let insets = UIEdgeInsets(all: .spacing.m)
            switch card {
            case .captionedImage(let card, _):
                items.append(ContentCardView.ViewData(index: index,
                                                      image: nil,
                                                      imageURL: card.image,
                                                      title: card.title,
                                                      subtitle: card.description,
                                                      action: card.domain,
                                                      isDismisable: card.dismissible,
                                                      isClickable: card.clickAction != nil,
                                                      isSelected: isSelected,
                                                      insets: insets))
            case .classic(let card):
                items.append(ContentCardView.ViewData(index: index,
                                                      image: nil,
                                                      imageURL: nil,
                                                      title: card.title,
                                                      subtitle: card.description,
                                                      action: card.domain,
                                                      isDismisable: card.dismissible,
                                                      isClickable: card.clickAction != nil,
                                                      isSelected: isSelected,
                                                      insets: insets))
            }
        }
        return items
    }

    private func fetchAssets(for card: Braze.ContentCard.CaptionedImage) async throws -> UIImage? {
        do {
            let data = try await URLSession.shared.data(from: card.image).0
            if let image = UIImage(data: data) {
                return image
            } else {
                let error = BrazeError.invalidContnetCardImageData(card.image)
                card.context?.logError(error)
                throw error
            }
        } catch {
            let errorToThrow = BrazeError.failedToDownloadContentCardImage(card.image, error)
            card.context?.logError(errorToThrow)
            throw errorToThrow
        }
    }
}
