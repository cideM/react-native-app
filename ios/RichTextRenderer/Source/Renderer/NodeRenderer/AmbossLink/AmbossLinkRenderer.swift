//
//  AmbossLinkRenderer.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 21.01.21.
//

import Foundation
import UIKit

open class AmbossLinkRenderer: NodeRendering {
    public typealias NodeType = AmbossLink

    required public init() {}

    open func render(
        node: AmbossLink,
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

        let pharmaAmbossLinkRichTextAttribute = PharmaRichTextAttribute.ambossLink
        let attributes: [NSAttributedString.Key: Any] = [
            .link: node.data.uri,
            pharmaAmbossLinkRichTextAttribute.key: node[keyPath: pharmaAmbossLinkRichTextAttribute.keyPath]
        ]
        result.addAttributes(attributes, range: result.fullRange)

        return [result]
    }
}
