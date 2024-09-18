// RichTextRenderer

import Foundation

public extension NSMutableAttributedString {

    static func makeNewLineString() -> NSMutableAttributedString {
        return .init(string: "\n")
    }

    func dropTrailingNewlines() {
      while string.hasSuffix("\n") {
        let range = NSRange(location: length - 1, length: 1)
        replaceCharacters(in: range, with: "")
      }
    }
}
