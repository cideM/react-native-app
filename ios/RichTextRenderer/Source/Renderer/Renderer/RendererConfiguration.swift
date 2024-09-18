// RichTextRenderer

import UIKit

/// Describes configuration of the `RichTextRenderer`.
public protocol RendererConfiguration {
    /// Provides fonts in different variations for the renderers.
    var fontProvider: FontProviding { get }

    /// Insets of the rendered content
    var contentInsets: UIEdgeInsets { get }

    /// Configuration for `Text` nodes.
    var textConfiguration: TextConfiguration { get }

    /// Configuration for `BlockQuote` nodes.
    var blockQuote: BlockQuoteConfiguration { get }

    /// Configuration for text lists.
    var textList: TextListConfiguration { get }

    /// Provides a view for `HorizontalRule` node.
    var horizontalRuleViewProvider: HorizontalRuleViewProviding { get }
    
    /// The background color to be used as a background of the text view
    var backgroundColor: UIColor { get }
}
