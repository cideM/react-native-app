//
//  NetworkError+PresentableMessage.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/11/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization

extension NetworkError: PresentableMessageType where T: PresentableMessageType {
    public var debugDescription: String {
        switch self {
        case .apiResponseError(let presentableErrors) where !presentableErrors.isEmpty: return presentableErrors.map { $0.debugDescription }.joined(separator: "\n")
        default: return "\(self)"
        }
    }

    public var title: String {
        switch self {
        case .apiResponseError(let presentableErrors): return presentableErrors.first?.title ?? L10n.Error.Generic.title
        case .noInternetConnection: return L10n.Error.Offline.title
        case .failed, .authTokenIsInvalid, .invalidFormat, .other, .requestTimedOut: return L10n.Error.Generic.title
        }
    }

    public var body: String {
        switch self {
        case .apiResponseError(let presentableErrors) where !presentableErrors.isEmpty: return presentableErrors.map { $0.body }.joined(separator: "\n")
        case .noInternetConnection: return L10n.Error.Offline.message
        case .failed, .authTokenIsInvalid, .invalidFormat, .other, .requestTimedOut, .apiResponseError: return L10n.Error.Generic.message
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .noInternetConnection: return .debug
        case .requestTimedOut: return .warning
        case .failed: return .warning
        case .authTokenIsInvalid: return .error
        case .invalidFormat: return .error
        case .apiResponseError(let presentableErrors): return presentableErrors.map { $0.logLevel }.max() ?? .info
        case .other: return .debug
        }
    }

    public var image: UIImage? {
        switch self {
        case .noInternetConnection: return Common.Asset.offline.image
        default: return nil
        }
    }
}
