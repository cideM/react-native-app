// RichTextRenderer

public struct DefaultRenderersProvider: NodeRenderersProviding {
    public var blockQuote: BlockQuoteRenderer = BlockQuoteRenderer()
    public var heading: HeadingRenderer = HeadingRenderer()
    public var horizontalRule: HorizontalRuleRenderer = HorizontalRuleRenderer()
    public var hyperlink: HyperlinkRenderer = HyperlinkRenderer()
    public var listItem: ListItemRenderer = ListItemRenderer()
    public var orderedList: OrderedListRenderer = OrderedListRenderer()
    public var paragraph: ParagraphRenderer = ParagraphRenderer()
    public var noWrapContainer: NoWrapContainerRenderer = NoWrapContainerRenderer()
    public var text: TextRenderer = TextRenderer()
    public var unorderedList: UnorderedListRenderer = UnorderedListRenderer()
    public var phrasionary: PhrasionaryRenderer = PhrasionaryRenderer()
    public var ambossLink: AmbossLinkRenderer = AmbossLinkRenderer()
    public var superscript: SuperscriptRenderer = SuperscriptRenderer()
    public var `subscript`: SubscriptRenderer = SubscriptRenderer()
    public var lineBreak: LineBreakRenderer = LineBreakRenderer()

    public init() {}
}
