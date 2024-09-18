// RichTextRenderer

extension BlockQuote: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .blockQuote(self)
    }
}

extension Heading: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .heading(self)
    }
}

extension HorizontalRule: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .horizontalRule(self)
    }
}

extension Hyperlink: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .hyperlink(self)
    }
}

extension ListItem: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .listItem(self)
    }
}

extension LineBreak: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .lineBreak(self)
    }
}

extension OrderedList: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .orderedList(self)
    }
}

extension Paragraph: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .paragraph(self)
    }
}

extension NoWrapContainer: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .noWrapContainer(self)
    }
}

extension Text: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .text(self)
    }
}

extension UnorderedList: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .unorderedList(self)
    }
}

extension Phrasionary: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .phrasionary(self)
    }
}

extension AmbossLink: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .ambossLink(self)
    }
}

extension Superscript: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .superscript(self)
    }
}

extension Subscript: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .subscript(self)
    }
}

