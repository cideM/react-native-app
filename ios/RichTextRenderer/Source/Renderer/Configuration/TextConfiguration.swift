// RichTextRenderer

import UIKit
import CoreGraphics

/// Configuration for rendering `Text` node.
public struct TextConfiguration {
    public let textColor: UIColor
    public let paragraphSpacing: CGFloat
    public let lineSpacing: CGFloat

    public init(
        fontColor: UIColor,
        paragraphSpacing: CGFloat,
        lineSpacing: CGFloat
    ) {
        self.textColor = fontColor
        self.paragraphSpacing = paragraphSpacing
        self.lineSpacing = lineSpacing
    }
}
