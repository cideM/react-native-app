//
//  ExternalAddition.swift
//  Interfaces
//
//  Created by Silvio Bulla on 03.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias ExternalAdditionIdentifier = Identifier<ExternalAddition, String>

public struct ExternalAddition: Codable {
    public let identifier: ExternalAdditionIdentifier
    public let type: ExternalAddition.Types
    public let isFree: Bool
    public let url: URL?

    private enum CodingKeys: String, CodingKey {
        case identifier = "key"
        case type = "feature"
        case isFree = "always_free"
        case url
    }

    private enum TypeCodingKeys: String, CodingKey {
        case id
    }

    // sourcery: fixture:
    public init(identifier: ExternalAdditionIdentifier, type: ExternalAddition.Types, isFree: Bool, url: URL?) {
        self.identifier = identifier
        self.type = type
        self.isFree = isFree
        self.url = url
    }
    // init(from decoder:) is required here for parsing "imageresources.json" inside the library archive
    // Each object there contains a "feature_keys" array which can contain "features"
    // These "features" are now mapped to "ExternalAddition.Type"
    // The domain object for "ExternalAddition" was formerly called "FeatureKey" but was refactored
    // Hence the JSON and the actual domain object look pretty different
    // we should consider seperating this into data models and domain models in the future.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeContainer = try container.nestedContainer(keyedBy: TypeCodingKeys.self, forKey: .type)
        type = try typeContainer.decode(ExternalAddition.Types.self, forKey: .id)
        identifier = ExternalAdditionIdentifier(value: try container.decode(String.self, forKey: .identifier))
        isFree = try container.decode(Bool.self, forKey: .isFree)
        url = nil
    }
}

// See here for an overview and descriptions of the keys
// https://www.notion.so/amboss-medical/Media-viewer-features-DRAFT-e711b7efe1304d5b92c18bbf99e948ca
public extension ExternalAddition {
    // sourcery: fixture:
    enum Types: Equatable {
        case smartzoom
        case meditricks
        case meditricksNeuroanatomy
        case miamedCalculator
        case miamedWebContent
        case miamedAuditor
        case miamedPatientInformation
        case miamed3dModel
        case video
        case easyradiology
        case other(String)
    }
}

extension ExternalAddition.Types: RawRepresentable, Codable {

    public typealias RawValue = String

    public var rawValue: String {
        switch self {
        case .smartzoom: return "smartzoom"
        case .meditricks: return "meditricks"
        case .meditricksNeuroanatomy: return "meditricks_neuroanatomy"
        case .miamedCalculator: return "miamed_calculator"
        case .miamedWebContent: return "miamed_web_content"
        case .miamedAuditor: return "miamed_auditor"
        case .miamedPatientInformation: return "miamed_patient_information"
        case .miamed3dModel: return "miamed_3d_model"
        case .video: return "video"
        case .easyradiology: return "easyradiology"
        case .other(let string): return string
        }
    }

    public init(rawValue: String) {
        switch rawValue {
        case "smartzoom": self = .smartzoom
        case "meditricks": self = .meditricks
        case "meditricks_neuroanatomy": self = .meditricksNeuroanatomy
        case "miamed_calculator": self = .miamedCalculator
        case "miamed_web_content": self = .miamedWebContent
        case "miamed_auditor": self = .miamedAuditor
        case "miamed_patient_information": self = .miamedPatientInformation
        case "miamed_3d_model": self = .miamed3dModel
        case "video": self = .video
        case "easyradiology": self = .easyradiology
        default: self = .other(rawValue)
        }
    }

    public var hasPlaceholderImage: Bool {
        switch self {
        case .smartzoom, .easyradiology: return false
        default: return true
        }
    }
}
