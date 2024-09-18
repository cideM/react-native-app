// RichTextRenderer

import UIKit

/// Default configuration for the `RichTextRenderer`.
public struct DefaultRendererConfiguration: RendererConfiguration {
    public var fontProvider: FontProviding
    public var contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 15)
    public var textConfiguration: TextConfiguration = .default
    public var blockQuote: BlockQuoteConfiguration = .default
    public var textList: TextListConfiguration = .default
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()
    public var backgroundColor: UIColor = .rtrSystemBackground

    public init(fontProvider: FontProviding = DefaultFontProvider()) {
        self.fontProvider = fontProvider
    }
}
