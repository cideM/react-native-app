//
//  GalleryImageToolbarDatasource.swift
//  Knowledge
//
//  Created by CSH on 11.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

enum GalleryImageToolbarDatasource {

    static func button(title: String, image: UIImage) -> PillToolbarButton {
        let view = PillToolbarButton(title: title, image: image)
        return view
    }

    static func button(for externalAddition: ExternalAddition) -> PillToolbarButton {
        let type: ExternalAddition.Types = externalAddition.type
        let button = PillToolbarButton(title: title(for: type), image: image(for: type))
        button.isMomentary = true
        return button
    }

    private static func image(for type: ExternalAddition.Types) -> UIImage {
        switch type {
        case .smartzoom: return Asset.Icon.Feature.smartzoom.image
        case .meditricks: return Asset.Icon.Feature.meditricks.image
        case .meditricksNeuroanatomy: return Asset.Icon.Feature.meditricks.image
        case .easyradiology: return Asset.Icon.Feature.easyradiology.image
        default: return Asset.Icon.Feature.default.image
        }
    }

    private static func title(for type: ExternalAddition.Types) -> String {
        switch type {
        case .smartzoom: return L10n.Gallery.Pill.Feature.Title.smartzoom
        case .meditricks: return L10n.Gallery.Pill.Feature.Title.meditricks
        case .meditricksNeuroanatomy: return L10n.Gallery.Pill.Feature.Title.meditricksNeuroanatomy
        case .miamedCalculator: return L10n.Gallery.Pill.Feature.Title.miamedCalculator
        case .miamedWebContent: return L10n.Gallery.Pill.Feature.Title.miamedWebContent
        case .miamedAuditor: return L10n.Gallery.Pill.Feature.Title.miamedAuditor
        case .miamedPatientInformation: return L10n.Gallery.Pill.Feature.Title.miamedPatientInformation
        case .miamed3dModel: return L10n.Gallery.Pill.Feature.Title.miamed3dModel
        case .video: return L10n.Gallery.Pill.Feature.Title.video
        case .easyradiology: return L10n.Gallery.Pill.Feature.Title.easyradiology
        case .other:
            // No entrys of this kind in imageresources.json -> unused as of now
            // It contains a custom title value but we do not use this here
            // since the space in the pill bar is so limited and the title
            // would likely break the layout ...
            return L10n.Gallery.Pill.Feature.Title.other
        }
    }
}
