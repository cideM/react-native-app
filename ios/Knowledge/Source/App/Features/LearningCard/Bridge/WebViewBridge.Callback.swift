//
//  WebViewBridge.Callback.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension WebViewBridge {
    enum Callback {
        case `init`
        case openLearningCard(_ learningCardDeeplink: LearningCardDeeplink)
        case showTable(_ html: HtmlDocument)
        case showPopover(_ html: HtmlDocument, tooltipType: String?)
        case closePopover
        case showImageGallery(_ gallery: GalleryDeeplink)
        case commitFeedback(_ feedbackDeeplink: FeedbackDeeplink)
        case editExtension(_ section: LearningCardSectionIdentifier)
        case sendMessageToUser(_ userIdentifier: UserIdentifier)
        case manageSharedExtensions
        case showVideo(_ video: Video)
        case onSectionOpened(_ sectionID: LearningCardAnchorIdentifier)
        case onSectionClosed(_ sectionID: LearningCardAnchorIdentifier)
        case blurredTrademarkTapped
        case dosageTapped(_ dosageID: DosageIdentifier)

        var name: Callbackname {
            switch self {
            case .`init`: return .`init`
            case .openLearningCard: return .openLearningCard
            case .showTable: return .showTable
            case .showPopover: return .showBonus
            case .closePopover: return .closeBonus
            case .showImageGallery: return .showImageGallery
            case .commitFeedback: return .commitFeedback
            case .editExtension: return .editExtension
            case .sendMessageToUser: return .sendMessageToUser
            case .manageSharedExtensions: return .manageSharedExtensions
            case .showVideo: return .showVideo
            case .onSectionOpened: return .onSectionOpened
            case .onSectionClosed: return .onSectionClosed
            case .blurredTrademarkTapped: return .blurredTrademarkTapped
            case .dosageTapped: return .dosageTapped
            }
        }

        init?(name: String, arguments: [Any]) {
            switch name {
            case "init":
                self = .`init`

            case "openLearningCard":
                guard let learningCard = arguments[0] as? String,
                      let anchor = arguments[2] as? String,
                      let source = arguments[4] as? String else {
                    return nil
                }
                self = .openLearningCard(LearningCardDeeplink(learningCard: LearningCardIdentifier(value: learningCard), anchor: LearningCardAnchorIdentifier(anchor), particle: nil, sourceAnchor: LearningCardAnchorIdentifier(source)))

            case "showTable":
                guard let html = arguments[0] as? String else { return nil }
                let document = HtmlDocument.tableDocument(html)
                self = .showTable(document)

            case "showBonus":
                guard let encodedContentString = arguments[0] as? String,
                      let encodedData = Data(base64Encoded: encodedContentString, options: []),
                      let decodedHtml = String(data: encodedData, encoding: .utf8)
                else { return nil }
                let document = HtmlDocument.popoverDocument(decodedHtml)
                let tooltipType = arguments[1] as? String
                self = .showPopover(document, tooltipType: tooltipType)

            case "closeBonus":
                self = .closePopover

            case "showImageGallery":
                guard let galleryId = arguments[0] as? String,
                      let imageIndexString = arguments[1] as? String,
                      let imageIndex = Int(imageIndexString) else {
                    return nil
                }
                self = .showImageGallery(GalleryDeeplink(gallery: GalleryIdentifier(value: galleryId), imageOffset: imageIndex))

            case "commitFeedback":
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let encodedContentString = arguments[0] as? String, let encodedData = Data(base64Encoded: encodedContentString, options: []), let feedbackContext = try? decoder.decode(FeedbackContext.self, from: encodedData), let sectionContext = feedbackContext.context else { return nil }
                self = .commitFeedback(FeedbackDeeplink(anchor: LearningCardAnchorIdentifier(sectionContext.modelId), version: sectionContext.modelVersion, archiveVersion: 0))

            case "editExtension":
                guard let sectionIdentifier = arguments[0] as? String else { return nil }
                self = .editExtension(LearningCardSectionIdentifier(value: sectionIdentifier))

            case "sendMessageToUser":
                guard let userId = arguments[0] as? String else { return nil }
                self = .sendMessageToUser(UserIdentifier(value: userId))

            case "manageSharedExtensions":
                self = .manageSharedExtensions

            case "showVideo":
                guard let type = arguments[0] as? String, let id = arguments[1] as? String else { return nil }
                switch type {
                case "youtube": self = .showVideo(.youtube(id))
                case "vimeo": self = .showVideo(.vimeo(id))
                default: return nil
                }

            case "onSectionOpened":
                guard let id = arguments[0] as? String else { return nil }
                self = .onSectionOpened(LearningCardAnchorIdentifier(value: id))

            case "onSectionClosed":
                guard let id = arguments[0] as? String else { return nil }
                self = .onSectionClosed(LearningCardAnchorIdentifier(value: id))
            case "blurredTrademarkTapped":
                self = .blurredTrademarkTapped

            case "dosageTapped":
                guard let dosageId = arguments[0] as? String else { return nil }
                self = .dosageTapped(.init(value: dosageId))

            default:
                return nil
            }
        }
    }
    enum Callbackname: String, CaseIterable {
        case `init`
        case openLearningCard
        case showTable
        case showBonus
        case closeBonus
        case showImageGallery
        case commitFeedback
        case editExtension
        case sendMessageToUser
        case manageSharedExtensions
        case showVideo
        case onSectionOpened
        case onSectionClosed
        case blurredTrademarkTapped
        case dosageTapped
    }
}
