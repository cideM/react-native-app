//
//  AppReviewPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 28.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import StoreKit

protocol AppReviewPresenterType {
    func displayAppReviewPromptIfNeeded()
}

final class AppReviewPresenter: AppReviewPresenterType {
    private let appReviewRepository: AppReviewRepositoryType

    init(appReviewRepository: AppReviewRepositoryType = resolve()) {
        self.appReviewRepository = appReviewRepository
    }

    func displayAppReviewPromptIfNeeded() {
        if appReviewRepository.shouldDisplayAppReviewPrompt() {
            if let windowScene = windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                appReviewRepository.appReviewPromptWasDisplayed()
            }
        }
    }

    private var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}
