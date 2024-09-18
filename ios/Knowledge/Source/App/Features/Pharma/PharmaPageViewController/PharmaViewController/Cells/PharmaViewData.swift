//
//  PharmaViewData.swift
//  Knowledge
//
//  Created by Silvio Bulla on 21.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

struct PharmaViewData {

    enum SectionViewData {

        struct SegmentedControlConfig {
            let title: String
            let anchor: String
            let isEmpty: Bool
            let isSelected: Bool
        }

        case substance(PharmaSubstanceSectionViewData)
        case drug(PharmaDrugSectionViewData)
        case section(PharmaSectionViewData)
        case prescribingInfo(PharmaPrescribingInfoViewData)
        case simpleTitle(text: String, isHighlighted: Bool)
        case feedback
        case segmentedControl([SegmentedControlConfig])

        var isExpanded: Bool {
            switch self {
            case .substance: return true
            case .drug: return true
            case .section(let data): return data.isExpanded
            case .prescribingInfo(let data): return data.hasAnyPDFURL
            case .simpleTitle: return true
            case .feedback: return true
            case .segmentedControl: return true
            }
        }

        var isExpandable: Bool {
            switch self {
            case .substance: return true
            case .drug: return true
            case .section: return true
            case .prescribingInfo(let data): return data.hasAnyPDFURL
            case .simpleTitle: return false
            case .feedback: return false
            case .segmentedControl: return false
            }
        }

        var isHeaderVisble: Bool {
            switch self {
            case .substance: return false
            case .drug: return false
            case .section(let data): return data.isHeaderVisible
            case .prescribingInfo: return false
            case .simpleTitle: return true
            case .feedback: return false
            case .segmentedControl: return false
            }
        }

        var title: String? {
            switch self {
            case .substance: return nil
            case .drug: return nil
            case .section(let data): return data.title
            case .prescribingInfo: return nil
            case .simpleTitle(let string, _): return string
            case .feedback: return nil
            case .segmentedControl: return nil
            }
        }

        var isHighlighted: Bool {
            switch self {
            case .substance: false
            case .drug: false
            case .section: false
            case .prescribingInfo: false
            case .simpleTitle(_, let highlighted): highlighted
            case .feedback: false
            case .segmentedControl: false
            }
        }

        var attributedTitle: NSAttributedString? {
            switch self {
            case .substance(let data): return data.title
            case .drug(let data): return data.title
            case .section: return nil
            case .prescribingInfo: return nil
            case .simpleTitle: return nil
            case .feedback: return nil
            case .segmentedControl: return nil
            }
        }
    }

    let title: String
    var sections: [SectionViewData]

    var prescribingInfoSection: PharmaPrescribingInfoViewData? {
        for section in sections {
            if case .prescribingInfo(let data) = section { return data }
        }
        return nil
    }

    init(substance: Substance, drug: Drug?) {
        self.title = substance.name
        let substanceSection = SectionViewData.substance(PharmaSubstanceSectionViewData(substance: substance, canSwitchDrug: drug != nil))
        var positionsAndsections: [(Int, SectionViewData)] = []

        if let drug = drug {
            let drugSection = SectionViewData.drug(PharmaDrugSectionViewData(drug: drug, dateFormatter: Self.formatLastUpdate))

            positionsAndsections = drug.sections
                .enumerated()
                .map { index, data in
                    // "data.position" is optional, it should always have a value though
                    // but just in case it does not we're deriving the position value from its place in the JSON array
                    (data.position ?? index, .section(PharmaSectionViewData(pharmaSection: data)))
                }
                .sorted { positionAndData1, positionAndData2 in positionAndData1.0 < positionAndData2.0 }

            // "0" -> value is never used, only required to satisfy array constraints
            let prescribingInfoSection = SectionViewData.prescribingInfo(PharmaPrescribingInfoViewData(drug: drug))
            positionsAndsections.append((0, prescribingInfoSection))

            positionsAndsections.append((0, SectionViewData.feedback))
            positionsAndsections.insert((0, drugSection), at: 0)

        }

        positionsAndsections.insert((0, substanceSection), at: 0)

        sections = positionsAndsections.map { $1 }
    }

    init?(pocketCard: PocketCard, group anchor: String? = nil, pocketCardAnchor: String? = nil) {

        // Init with a link to a non existing or empty group fails cause this would cause UI errors
        if let anchor {
            if let group = pocketCard.groups.first(where: { $0.anchor == anchor }) {
                if group.sections.isEmpty {
                    return nil
                }
            } else {
                return nil
            }
        }

        title = ""
        var sections = [SectionViewData]()

        var group: PocketCard.Group?
        if anchor == nil {
            group = pocketCard.groups.first(where: { !$0.sections.isEmpty })
        } else if let anchor, let _group = pocketCard.groups.first(where: { $0.anchor == anchor }) {
            group = _group
        }

        guard let group else { return nil }
        for section in group.sections {
            sections.append(
                SectionViewData.simpleTitle(
                    text: section.title,
                    isHighlighted: pocketCardAnchor != nil && pocketCardAnchor == section.anchor)
            )
            sections.append(
                SectionViewData.section(.init(section: section))
            )
        }

        sections.insert(
            SectionViewData.segmentedControl(
                pocketCard.groups.map { _group in
                    SectionViewData.SegmentedControlConfig(
                        title: _group.title,
                        anchor: _group.anchor,
                        isEmpty: _group.sections.isEmpty,
                        isSelected: _group.anchor == group.anchor)
                }
            ), at: 0)

        self.sections = sections
    }

    private static func formatLastUpdate(publishedAt: String) -> String? {
        if let publishedAtDate = ISO8601DateFormatter().date(from: publishedAt) {
            return DateFormatter.defaultDisplayDateOnlyDateFormatter.string(from: publishedAtDate)
        }

        return nil
    }
}

extension Prescription: CustomStringConvertible {
    public var description: String {
        switch self {
        case .overTheCounter: return L10n.Substance.Prescription.overTheCounter
        case .pharmacyOnly: return L10n.Substance.Prescription.pharmacyOnly
        case .prescriptionOnly: return L10n.Substance.Prescription.prescriptionOnly
        case .narcotic: return L10n.Substance.Prescription.narcotic
        }
    }
}
