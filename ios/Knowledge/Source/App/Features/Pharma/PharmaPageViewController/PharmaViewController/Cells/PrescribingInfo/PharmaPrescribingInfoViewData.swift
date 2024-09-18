//
//  PharmaFooterViewData.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

struct PharmaPrescribingInfoViewData {
    let prescribingInformationSectionTitle: NSAttributedString
    let prescribingInformationSectionValue: NSAttributedString?

    let prescribingInformationTitle: NSAttributedString?
    let prescribingInformationSubtitle: NSAttributedString?
    let prescribingInformationUrl: URL?

    let patientPackageTitle: NSAttributedString?
    let patientPackageSubtitle: NSAttributedString?
    let patientPackageInsertUrl: URL?

    var hasAnyPDFURL: Bool {
        let hasPackageURL = !(patientPackageInsertUrl?.absoluteString ?? "").isEmpty
        let hasInfoURL = !(prescribingInformationUrl?.absoluteString ?? "").isEmpty
        return hasInfoURL || hasPackageURL
    }

    init(drug: Drug) {
        prescribingInformationSectionTitle = NSAttributedString(string: L10n.Substance.prescribingInformationSectionLabel.uppercased(), attributes: ThemeManager.currentTheme.agentPrescribingInformationSectionLabelTextAttributes)
        prescribingInformationSectionValue = NSAttributedString(string: L10n.Substance.ifapInformationNote(drug.name), attributes: ThemeManager.currentTheme.agentPrescribingInformationSectionValueLabelTextAttributes)

        if drug.prescribingInformationUrl.isNonEmpty {
            prescribingInformationTitle = NSAttributedString(string: L10n.Substance.prescribingInformationLabel, attributes: ThemeManager.currentTheme.agentPrescribingInformationLabelTextAttributes)
            prescribingInformationSubtitle = NSAttributedString(string: L10n.Substance.prescribingInformationSubtitleLabel, attributes: ThemeManager.currentTheme.agentPrescribingInformationSubtitleLabelTextAttributes)
        } else {
            prescribingInformationTitle = nil
            prescribingInformationSubtitle = nil
        }

        if drug.patientPackageInsertUrl.isNonEmpty {
            patientPackageTitle = NSAttributedString(string: L10n.Substance.patientPackageLabel, attributes: ThemeManager.currentTheme.agentPatientPackageLabelTextAttributes)
            patientPackageSubtitle = NSAttributedString(string: L10n.Substance.patientPackageSubtitleLabel, attributes: ThemeManager.currentTheme.agentPatientPackageSubtitleLabelTextAttributes)
        } else {
            patientPackageTitle = nil
            patientPackageSubtitle = nil
        }

        if let prescribingInformationUrlString = drug.prescribingInformationUrl, let prescribingInformationUrl = URL(string: prescribingInformationUrlString) {
            self.prescribingInformationUrl = prescribingInformationUrl
        } else {
            self.prescribingInformationUrl = nil
        }

        if let patientPackageInsertUrlString = drug.patientPackageInsertUrl, let patientPackageInsertUrl = URL(string: patientPackageInsertUrlString) {
            self.patientPackageInsertUrl = patientPackageInsertUrl
        } else {
            self.patientPackageInsertUrl = nil
        }
    }
}
