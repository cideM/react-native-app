// RichTextRenderer

import UIKit

open class NoWrapContainerRenderer: NodeRendering {
    public typealias NodeType = NoWrapContainer

    required public init() {}

    open func render(
        node: NoWrapContainer,
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

        // WORKAROUND:
        // Inserting "word joiner" character everywhere to prevent breaking (https://unicode-explorer.com/c/2060)
        // Inserting "non breaking zero width" would also work (https://unicode-explorer.com/c/FEFF)
        // There is no other way to prevent linebreaks in attributed strings
        // No, also NSMutableParagraphStyle.lineBreakMode does not work.
        result.insert(afterEveryCharacter: "\u{2060}")

        return [result]
    }
}

fileprivate extension NSMutableAttributedString {
    func insert(afterEveryCharacter insertString: String) {
        for index in (0..<self.length).reversed() {
            let insertAttributedString = NSAttributedString(string: insertString)
            self.insert(insertAttributedString, at: index + 1)
        }
    }
}
