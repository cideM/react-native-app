//
//  PharmaCardDeeplink.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 09.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PharmaCardDeeplink: Equatable {

    public enum DocumentType: Equatable {
        public enum AuxiliaryPresentation: Equatable {
            case none
            case drugSelector
        }

        case ifap(AuxiliaryPresentation)
        // "group" is a string here cause it can be really anything
        // it currently typically is  `adult` or `pc_pediatric` but can be others in future
        // The UI is already built in a way that it will adapt (hopefully)
        case pocketCard(group: String?, anchor: String?)

        init?(document: String?, group: String?, fragment: String?) {
            switch document {
            case "ifap":
                self = .ifap(.none)
            case "pocket_card":
                // provided via query parameters
                // group: `?document=pocketcard`
                // anchor == fragment (the one with the "#"): `?document=pocketcard#pc_adult_dani`
                self = .pocketCard(group: group, anchor: fragment)

            default:
                switch fragment {
                case "pocketcard":
                    self = .pocketCard(group: group, anchor: nil) // provided via fragment `#pocketcard`
                case "ifap_drug_selector":
                    self = .ifap(.drugSelector)
                default:
                    if let fragment {
                        self = .pocketCard(group: group, anchor: fragment)
                    } else {
                        return nil
                    }
                }
            }
        }
    }

    public let substance: SubstanceIdentifier
    public let drug: DrugIdentifier?
    public let document: DocumentType?

    // sourcery: fixture:
    public init(substance: SubstanceIdentifier, drug: DrugIdentifier?) {
        self.substance = substance
        self.drug = drug
        self.document = nil
    }

    public init(substance: SubstanceIdentifier, drug: DrugIdentifier?, document: DocumentType?) {
        self.substance = substance
        self.drug = drug
        self.document = document
    }

    init(substance: String, drug: String) {
        self.substance = SubstanceIdentifier(value: substance)
        self.drug = DrugIdentifier(value: drug)
        self.document = nil
    }

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        // Old pharma link style: /de/pharma/:agent/:drug
        case ["de", "pharma", .xid(length: nil), .xid(length: nil)]:
            self.init(substance: urlComponents.pathComponents[2], drug: urlComponents.pathComponents[3])

        // New pharma link style: /pharma/{ambossSubstanceID}?[query_param1={value1}*n][#anchor]
        case ["de", "pharma", .xid(length: nil)]:
            let substance = SubstanceIdentifier(urlComponents.pathComponents[2])
            let query = urlComponents.queryItems
            let document = DocumentType(document: query?["document"],
                                        group: query?["pc_group"],
                                        fragment: urlComponents.fragment)

            let drug: DrugIdentifier? = if let id = query?["drug_id"] {
                .init(id)
            } else {
                nil
            }

            if let substance {
                self.init(substance: substance, drug: drug, document: document)
            } else {
                return nil
            }

        default:
            return nil
        }
    }

}
