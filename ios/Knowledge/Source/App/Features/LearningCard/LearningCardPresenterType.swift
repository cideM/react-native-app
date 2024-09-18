//
//  LearningCardPresenterType.swift
//  Knowledge DE
//
//  Created by Vedran Burojevic on 01/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol LearningCardPresenterType: WebViewBridgeDelegate {
    var view: LearningCardViewType? { get set }
    func go(to learningCardDeeplink: LearningCardDeeplink)
    func goToPreviousLearningCard()
    func goToNextLearningCard()
    func closeLearningCardOverlay()
    func closeAllSections()
    func openAllSections()
    func toggleIsFavorite()
    func showInArticleSearch()
    func showLearningCardOptions()
    func openURL(_ url: URL)
    func showMiniMap()
    func shareLearningCard()
    func showError(title: String, message: String)
}
