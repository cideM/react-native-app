//
//  PhrasionaryRenderer.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 21.01.21.
//

import Foundation
import UIKit

open class PhrasionaryRenderer: NodeRendering {
    public typealias NodeType = Phrasionary

    required public init() {}

    open func render(
        node: Phrasionary,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }.reduce(into: NSMutableAttributedString()) { result, child in
            result.append(child)
        }
        
        let pharmaPhrasionaryRichTextAttribute = PharmaRichTextAttribute.phrasionary
        let attributes: [NSAttributedString.Key: Any] = [
            pharmaPhrasionaryRichTextAttribute.key: node[keyPath: pharmaPhrasionaryRichTextAttribute.keyPath],
            .link: "" // Phrasionaries are always rendered as tappable links even if they don't contain an AmbossLink node. If they contain an AmbossLink node; AmbossLinkRenderer will override the value associated with this NSAttributedKey with an actual link. Otherwise, the url is completely ignored and only used to catch the tap even in UITextViewDelegate.
        ]
        result.addAttributes(attributes, range: result.fullRange)

        return [result]
    }
}
