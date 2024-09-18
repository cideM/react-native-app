//
//  LineBreakRenderer.swift
//  RichTextRenderer
//
//  Created by Silvio Bulla on 26.01.21.
//

import UIKit

open class LineBreakRenderer: NodeRendering {
    public typealias NodeType = LineBreak

    required public init() {}

    open func render(node: LineBreak, rootRenderer: RichTextDocumentRendering, context: [CodingUserInfoKey : Any]) -> [NSMutableAttributedString] {

        return [.makeNewLineString()]
    }
}
