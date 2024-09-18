//
//  SubscriptRenderer.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 21.01.21.
//

import Foundation

open class SubscriptRenderer: NodeRendering {
    public typealias NodeType = Subscript

    required public init() {}

    open func render(
        node: Subscript,
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

        result.addAttributes(
            [.baselineOffset: -5],
            range: result.fullRange
        )

        return [result]
    }
}
