//
//  ContentCardsPresenter.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 26.10.23.
//

import DesignSystem
import UIKit

extension ContentCardView.ViewData: GenericListViewData { }

class ContentCardsPresenter: GenericListViewPresenterType {
    typealias View = GenericListTableViewController<ContentCardsDataSource, ContentCardsPresenter>
    
    var view: View? {
        didSet {
            view?.title = "Conten Cards"
            view?.update(with: dummy())
        }
    }
    
    func dummy() -> [ContentCardView.ViewData] {
        return [
            // image
            ContentCardView.ViewData(index: 0,
                                     image: nil,
                                     imageURL: URL(string: "https://cdn.braze.eu/appboy/communication/marketing/content_cards_message_variations/images/649ae82af519543b5d1f7a3d/f8d24bd39cd16b9d35b4f6fbe8e38f33d8d56bbb/original.jpg?1687873794"),
                                     title: "Title of the image content card",
                                     subtitle: "Subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card.",
                                     action: "GO TO ARTICLE",
                                     isDismisable: true,
                                     isClickable: true,
                                     isSelected: false,
                                     insets: .init(all: .spacing.m)),
            // text
            ContentCardView.ViewData(index: 0,
                                     image: nil,
                                     imageURL: nil,
                                     title: "Title of the text content card",
                                     subtitle: "Subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card, subtitle of the content card.",
                                     action: "GO TO ARTICLE",
                                     isDismisable: true,
                                     isClickable: true,
                                     isSelected: false,
                                     insets: .init(all: .spacing.m))
        ]
    }
}
