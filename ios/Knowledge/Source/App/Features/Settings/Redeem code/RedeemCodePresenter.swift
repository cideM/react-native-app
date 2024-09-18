//
//  RedeemCodePresenter.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 20.12.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Networking
import Localization

protocol RedeemCodePresenterType: AnyObject {
    var view: RedeemCodeViewType? { get set }

    func codeDidChange(code: String)
    func redeemButtonTapped(code: String)
    func helpButtonTapped()
}

class RedeemCodePresenter: RedeemCodePresenterType {

    weak var view: RedeemCodeViewType? {
        didSet {
            view?.setCallout(message: L10n.RedeemCode.Callout.Title.info,
                              type: .informational,
                              animated: false)
            view?.setCode(initialCode)
        }
    }
    private var initialCode: String
    private var isShowingError = false
    private var isCodeRedeemed = false
    private let accessClient: MembershipAccessClient
    private let coordinator: SettingsCoordinatorType

    init(code: String? = nil,
         accessClient: MembershipAccessClient = resolve(),
         coordinator: SettingsCoordinatorType) {
        self.initialCode = code ?? ""
        self.accessClient = accessClient
        self.coordinator = coordinator
    }

    func codeDidChange(code: String) {
        if isShowingError {
            isShowingError = false
            view?.setCallout(message: L10n.RedeemCode.Callout.Title.info,
                             type: .informational,
                             animated: true)
        }
    }

    func redeemButtonTapped(code: String) {
        if isCodeRedeemed {
            coordinator.goBackToSettings()
        } else {
            redeem(code: code)
        }
    }

    func redeem(code: String) {
        self.view?.setLoading(true)
        accessClient.applyAccessCode(code: code) { [weak self] result in
            guard let self = self else { return }
            self.view?.setLoading(false)

            switch result {
            case .success:
                self.isCodeRedeemed = true
                view?.setRedeemButtonTitle(L10n.RedeemCode.Button.Title.done)
                view?.setCallout(message: L10n.RedeemCode.Callout.Title.success,
                                  type: .success,
                                  animated: true)
            case .failure(let error):
                self.isShowingError = true
                view?.setCallout(message: self.message(for: error),
                                  type: .error,
                                  animated: true)

            }
        }
    }
    func helpButtonTapped() {
        coordinator.goToViewController(of: .supportus, animated: true)
    }

    private func message(for error: NetworkError<ProductKeyError>) -> String {
        switch error {
        case .noInternetConnection, .requestTimedOut:
            return L10n.Error.Internet.Message.title
        case .failed, .authTokenIsInvalid, .invalidFormat, .other:
            return L10n.Error.Generic.message
        case .apiResponseError(let applyCodeErrors):
            guard let applyCodeError = applyCodeErrors.first else { return "" }
            switch applyCodeError.errorType {
            case .keyNotValid:
                return L10n.RedeemCode.Error.keyNotValid
            case .alreadySubscribed:
                return L10n.RedeemCode.Error.alreadySubscribed
            case .unknown:
                return L10n.RedeemCode.Error.unknown
            }
        }
    }
}
