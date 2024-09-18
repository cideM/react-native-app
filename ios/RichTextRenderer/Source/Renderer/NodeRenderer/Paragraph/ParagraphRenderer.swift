// RichTextRenderer

import UIKit

/// A renderer for `Contentful.Paragraph` node.
open class ParagraphRenderer: NodeRendering {
    public typealias NodeType = Paragraph

    required public init() {}

    open func render(
        node: Paragraph,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        var result = contentNodes.reduce(into: [NSMutableAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }

        result.applyListItemStylingIfNecessary(node: node, context: context)
        
        // WORKAROUND: A lot of empty lines are added because we are wrapping the content of list items in paragraphs. So we need to make sure that we only add a new line to the end of a paragraph if there is no new line added there.
        if result.last?.string != "\n" {
            result.append(.makeNewLineString())
        }

        return result
    }
}
