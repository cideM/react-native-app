//
//  UsageStage+AgreementMessage.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import DesignSystem
import SwiftyStoreKit
import Localization

extension UserStage {
    var agreementMessage: NSAttributedString {
        let configuration: URLConfiguration = AppConfiguration.shared
        let message: NSMutableAttributedString

        switch self {
        case .physician:
            message = .attributedString(with: L10n.UserStage.footerAgreementClinician,
                                        style: .paragraph)
            let liabilityNoticeLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementLiabilityNoticeText)
            message.addAttributes(.inlineLink, range: liabilityNoticeLinkRange)
            message.addAttributes([.attachment: configuration.liabilityNoticeURL.dataRepresentation], range: liabilityNoticeLinkRange)

            let legalNoticeLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementLegalNoticeText)
            message.addAttributes(.inlineLink, range: legalNoticeLinkRange)
            message.addAttributes([.attachment: configuration.legalNoticeURL.dataRepresentation], range: legalNoticeLinkRange)

            let termsAndConditionsLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementTermsAndConditionsText)
            message.addAttributes(.inlineLink, range: termsAndConditionsLinkRange)
            message.addAttributes([.attachment: configuration.termsAndConditionsURL.dataRepresentation], range: termsAndConditionsLinkRange)

            let privacyPolicyLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementPrivacyPolicyText)
            message.addAttributes(.inlineLink, range: privacyPolicyLinkRange)
            message.addAttributes([.attachment: configuration.privacyURL.dataRepresentation], range: privacyPolicyLinkRange)

        case .clinic, .preclinic:
            message = .attributedString(with: L10n.UserStage.footerAgreementNonClinician, style: .paragraph)

            let legalNoticeLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementLegalNoticeText)
            message.addAttributes(.inlineLink, range: legalNoticeLinkRange)
            message.addAttributes([.attachment: configuration.legalNoticeURL.dataRepresentation], range: legalNoticeLinkRange)

            let termsAndConditionsLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementTermsAndConditionsText)
            message.addAttributes(.inlineLink, range: termsAndConditionsLinkRange)
            message.addAttributes([.attachment: configuration.termsAndConditionsURL.dataRepresentation], range: termsAndConditionsLinkRange)

            let privacyPolicyLinkRange = message.mutableString.range(of: L10n.UserStage.footerAgreementPrivacyPolicyText)
            message.addAttributes(.inlineLink, range: privacyPolicyLinkRange)
            message.addAttributes([.attachment: configuration.privacyURL.dataRepresentation], range: privacyPolicyLinkRange)
        }

        return message
    }
}
