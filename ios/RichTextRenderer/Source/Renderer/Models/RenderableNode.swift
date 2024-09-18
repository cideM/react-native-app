// RichTextRenderer

/// Concrete types representing renderable nodes.
public enum RenderableNode {
    case blockQuote(BlockQuote)
    case heading(Heading)
    case horizontalRule(HorizontalRule)
    case hyperlink(Hyperlink)
    case listItem(ListItem)
    case orderedList(OrderedList)
    case paragraph(Paragraph)
    case noWrapContainer(NoWrapContainer)
    case text(Text)
    case unorderedList(UnorderedList)
    case phrasionary(Phrasionary)
    case ambossLink(AmbossLink)
    case superscript(Superscript)
    case `subscript`(Subscript)
    case lineBreak(LineBreak)
}
