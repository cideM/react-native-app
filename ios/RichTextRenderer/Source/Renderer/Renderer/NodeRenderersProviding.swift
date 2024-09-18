// RichTextRenderer

import UIKit

public protocol NodeRenderersProviding {

    var blockQuote: BlockQuoteRenderer { get set }
    var heading: HeadingRenderer { get set }
    var horizontalRule: HorizontalRuleRenderer { get set }
    var hyperlink: HyperlinkRenderer { get set }
    var listItem: ListItemRenderer { get set }
    var lineBreak: LineBreakRenderer { get set }
    var orderedList: OrderedListRenderer { get set }
    var paragraph: ParagraphRenderer { get set }
    var noWrapContainer: NoWrapContainerRenderer { get set }
    var text: TextRenderer { get set }
    var unorderedList: UnorderedListRenderer { get set }
    var phrasionary: PhrasionaryRenderer { get set }
    var ambossLink: AmbossLinkRenderer { get set }
    var superscript: SuperscriptRenderer { get set }
    var `subscript`: SubscriptRenderer { get set }
}

extension NodeRenderersProviding {
    func render(
        node: RenderableNode,
        renderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        switch node {
        case .blockQuote(let blockQuote):
            return self.blockQuote.render(
                node: blockQuote,
                rootRenderer: renderer,
                context: context
            )

        case .heading(let heading):
            return self.heading.render(
                node: heading,
                rootRenderer: renderer,
                context: context
            )

        case .horizontalRule(let horizontalRule):
            return self.horizontalRule.render(
                node: horizontalRule,
                rootRenderer: renderer,
                context: context
            )

        case .hyperlink(let hyperlink):
            return self.hyperlink.render(
                node: hyperlink,
                rootRenderer: renderer,
                context: context
            )

        case .listItem(let listItem):
            return self.listItem.render(
                node: listItem,
                rootRenderer: renderer,
                context: context
            )

        case .lineBreak(let lineBreak):
            return self.lineBreak.render(
                node: lineBreak,
                rootRenderer: renderer,
                context: context
            )

        case .orderedList(let orderedList):
            return self.orderedList.render(
                node: orderedList,
                rootRenderer: renderer,
                context: context
            )
            
        case .noWrapContainer(let container):
            return self.noWrapContainer.render(
                node: container,
                rootRenderer: renderer,
                context: context
            )

        case .paragraph(let paragraph):
            return self.paragraph.render(
                node: paragraph,
                rootRenderer: renderer,
                context: context
            )

        case .text(let text):
            return self.text.render(
                node: text,
                rootRenderer: renderer,
                context: context
            )

        case .unorderedList(let unorderedList):
            return self.unorderedList.render(
                node: unorderedList,
                rootRenderer: renderer,
                context: context
            )
            
        case .phrasionary(let phrasionary):
            return self.phrasionary.render(
                node: phrasionary,
                rootRenderer: renderer,
                context: context
            )
            
        case .ambossLink(let ambossLink):
            return self.ambossLink.render(
                node: ambossLink,
                rootRenderer: renderer,
                context: context
            )
            
        case .superscript(let superscript):
            return self.superscript.render(
                node: superscript,
                rootRenderer: renderer,
                context: context
            )
            
        case .subscript(let `subscript`):
            return self.subscript.render(
                node: `subscript`,
                rootRenderer: renderer,
                context: context
            )
        }
    }
}
