//
//  MonographWebViewBridge.Events.swift
//  Knowledge
//
//  Created by Silvio Bulla on 21.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension MonographWebViewBridge {

    enum Error: Swift.Error {
        case unrecognizedEvent(payload: [String: Any])
        case unrecognizedEventAttributes(payload: [String: Any])
        case parsingError
    }

    /// Analytics events received from the `MonographWebViewBridge`.
    enum AnalyticsEvent {
        case genericEvent(eventName: String, properties: [String: Any])

        init(dictionary: [String: Any]) throws {
            guard let event = dictionary["event"] as? String else {
                throw Error.unrecognizedEventAttributes(payload: dictionary)
            }
            guard let properties = dictionary["properties"] as? [String: Any] else {
                throw Error.unrecognizedEventAttributes(payload: dictionary)
            }

            self = .genericEvent(eventName: event, properties: properties)
        }
    }

    /// These are the events (messages) received from the `MonographWebViewBridge`.
    enum Event {
        case initializeEnd
        case openLinkToMonograph(_ monographDeeplink: MonographDeeplink)
        case openLinkToSnippet(snippet: SnippetIdentifier)
        case openTable(title: String, html: String)
        case openLinkToAmboss(learningCardDeeplink: LearningCardDeeplink)
        case openLinkToExternalPage(url: URL)
        case referenceCalloutGroup(html: String)
        case feedbackButtonClicked
        case offLabelElementClicked(html: String)
        case tableAnnotationClicked(html: String)

        init(dictionary: [String: Any]) throws {
            guard let name = dictionary["name"] as? String,
                  let data = dictionary["data"] as? [String: Any] else { throw Error.unrecognizedEventAttributes(payload: dictionary) }

            switch name {
            case "initialize_end":
                self = .initializeEnd

            case "monograph_link_clicked":
                guard let monograph = data["monographId"] as? String,
                      let anchor = data["anchor"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                let monographId = MonographIdentifier(value: monograph)
                let anchorId = MonographAnchorIdentifier(value: anchor)
                self = .openLinkToMonograph(MonographDeeplink(monograph: monographId, anchor: anchorId))

            case "amboss_snippet_clicked":
                guard let snippet = data["phraseGroupEid"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                let snippetId = SnippetIdentifier(value: snippet)
                self = .openLinkToSnippet(snippet: snippetId)

            case "table_clicked":
                guard let title = data["title"] as? String,
                      let html = data["html"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                self = .openTable(title: title, html: html)

            case "amboss_link_clicked":
                guard let id = data["articleEid"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }

                var anchorId: LearningCardAnchorIdentifier?
                if let anchor = data["anchor"] as? String {
                    anchorId = LearningCardAnchorIdentifier(value: anchor)
                }

                let deeplink = LearningCardDeeplink(learningCard: LearningCardIdentifier(value: id),
                                                    anchor: anchorId,
                                                    particle: nil,
                                                    sourceAnchor: nil,
                                                    question: nil)
                self = .openLinkToAmboss(learningCardDeeplink: deeplink)

            case "external_link_clicked":
                guard let href = data["href"] as? String,
                      let url = URL(string: href) else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                self = .openLinkToExternalPage(url: url)

            case "reference_callout_group_clicked":
                guard let html = data["html"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                self = .referenceCalloutGroup(html: html)

            case "feedback_button_clicked":
                self = .feedbackButtonClicked

            case "off_label_element_clicked":
                guard let html = data["htmlContent"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                self = .offLabelElementClicked(html: html)

            case "table_annotation_clicked":
                guard let html = data["htmlContent"] as? String else { throw Error.unrecognizedEventAttributes(payload: dictionary) }
                self = .tableAnnotationClicked(html: html)

            default:
                throw Error.unrecognizedEvent(payload: dictionary)
            }
        }
    }
}
