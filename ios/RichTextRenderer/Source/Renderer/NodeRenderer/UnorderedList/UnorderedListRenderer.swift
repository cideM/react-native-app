// RichTextRenderer

import UIKit

/**
 A renderer for a `Contentful.UnorderedList` node. This renderer will mutate the passed-in context and pass in that
 mutated context to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered list
 index character) is prepended to the content and it will also ensure the proper indentation is applied
 to the contained content.
 */
open class UnorderedListRenderer: NodeRendering {
    public typealias NodeType = UnorderedList

    required public init() {}

    open func render(
        node: UnorderedList,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        var listContext: ListContext! = context[.listContext] as? ListContext
        if listContext == nil {
            listContext = ListContext(listType: .unordered)
        } else {
            listContext.itemIndex = 0
            listContext.level += 1

            if listContext.listType != .unordered {
                listContext.listType = .unordered
            }
        }

        var mutableContext = context
        mutableContext[.listContext] = listContext

        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSMutableAttributedString()]) { result, contentNode in
            mutableContext[.listContext] = listContext

            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: mutableContext
            )

            result.append(contentsOf: renderedNode)

            listContext.itemIndex += 1
        }

        // WORKAROUND:
        // Bullet point 'fullCircle' sits too low on the line when rendered, reason unclear
        // We're just shifting this upwards a bit to fix it
        //
        // This is quite hacky but gets the job done for this single character '●'
        // It looks okay for all font sizes of that character now
        // The other available kinds of bullet points ('◦' + '▪︎') will start to look
        // out of place if the font size derives substantially from 16pt, hence there is code to handle that as well
        //
        // Everything less hacky would have involved a lot of code changes since
        // the insertion of the character and font assignment happens in very different places
        // (NSMutableAttributedString+ArrayOperations vs ListItemRenderer)
        // The font height is required for the fix and hence piping this value through a lot of places
        // would have been necessary. We can cross that bridge at a later point if we really need it ...
        if  let configuration = context[.rendererConfiguration] as? RendererConfiguration {
            let lineHeight = configuration.fontProvider.regular.lineHeight

            for bullet in UnorderedListBullet.allCases {
                // '◦' + '▪︎' only needs shifting at large font sizes ...
                if lineHeight < 20 && bullet != .fullCircle {
                    continue
                }

                let bullet = bullet.rawValue

                for (index, attributedString) in result.enumerated() {
                    attributedString.string.enumerateSubstrings(
                        in: attributedString.string.startIndex..<attributedString.string.endIndex,
                        options: .byComposedCharacterSequences)
                    { string, range, _, _ in
                        if string == bullet {
                            let range = NSRange(range, in: attributedString.string)
                            let value = (lineHeight / 6) // <- guesstimated by trial and error
                            result[index].addAttribute(.baselineOffset, value: value, range: range)
                        }
                    }
                }
            }
        }

        return result
    }
}
