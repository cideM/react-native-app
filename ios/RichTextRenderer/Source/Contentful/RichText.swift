//
//  RichText.swift
//  Contentful
//
//  Created by JP Wright on 26.08.18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation

/// The base protocol which all node types that may be present in a tree of Structured text.
/// See: <https://www.contentful.com/developers/docs/tutorials/general/structured-text-field-type-alpha/> for more information.
public protocol Node: Codable {
    /// The type of node which should be rendered.
    var nodeType: NodeType { get }
}

public protocol RecursiveNode: Node {
    var content: [Node] { get }
}

internal enum NodeContentCodingKeys: String, CodingKey {
    case nodeType, content, data
}

/// A descriptor of the node's type, which can be used to determine rendering heuristics.
public enum NodeType: String, Codable {
    /// The top-level node type.
    case document
    /// A block of text, the parent node for inline text nodes.
    case paragraph
    /// A string of text which may not wrap
    /// Does not work as intended since NSAttributedString does not support this
    /// Added here in order to make the JSON richtext render properly
    /// in case this node is included (which it is in IFAP content - see: Amoxicillin -> pediatric)
    case noWrapContainer = "no-wrap-container"
    /// A string of text which may contain marks.
    case text
    /// A large heading.
    case h1 = "heading-1"
    /// A sub-heading.
    case h2 = "heading-2"
    /// An h3 heading.
    case h3 = "heading-3"
    /// An h4 heading.
    case h4 = "heading-4"
    /// An h5 heading.
    case h5 = "heading-5"
    /// An h6 heading.
    case h6 = "heading-6"
    /// A blockquote
    case blockquote
    /// A horizontal rule break.
    case horizontalRule = "horizontal-rule"
    /// An orderered list.
    case orderedList = "ordered-list"
    /// An unordered list.
    case unorderedList = "unordered-list"
    /// A list item in either an ordered or unordered list.
    case listItem = "list-item"

    // Links
    /// A hyperlink to a URI.
    case hyperlink
    
    /// A phrasionary node.
    case phrasionary = "phrasionary"
    /// An AMBOSS link node.
    case ambossLink = "link"
    /// A superscript node.
    case superscript = "superscript"
    /// A subscript node.
    case `subscript` = "subscript"
    /// A line break node.
    case lineBreak = "linebreak"

    internal var type: Node.Type {
        switch self {
        case .paragraph:
            return Paragraph.self
        case .noWrapContainer:
            return NoWrapContainer.self
        case .text:
            return Text.self
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return Heading.self
        case .document:
            return RichTextDocument.self
        case .blockquote:
            return BlockQuote.self
        case .horizontalRule:
            return HorizontalRule.self
        case .orderedList:
            return OrderedList.self
        case .unorderedList:
            return UnorderedList.self
        case .listItem:
            return ListItem.self
        case .hyperlink:
            return Hyperlink.self
        case .phrasionary:
            return Phrasionary.self
        case .ambossLink:
            return AmbossLink.self
        case .superscript:
            return Superscript.self
        case .subscript:
            return Subscript.self
        case .lineBreak:
            return LineBreak.self
        }
    }
}

public class NoContentNode: Node {
    public var nodeType: NodeType
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
    }
    
    public init(nodeType: NodeType) {
        self.nodeType = nodeType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
    }
}

/// BlockNode is the base class for all nodes which are rendered as a block (as opposed to an inline node).
public class BlockNode: RecursiveNode {
    public let nodeType: NodeType
    public internal(set) var content: [Node]

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
        content = try container.decodeContent(forKey: .content)
    }

    public init(nodeType: NodeType, content: [Node]) {
        self.nodeType = nodeType
        self.content = content
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encodeNodes(content, forKey: .content)
    }
}

/// InlineNode is the base class for all nodes which are rendered as an inline string (as opposed to a block node).
public class InlineNode: RecursiveNode {
    public let nodeType: NodeType
    public internal(set) var content: [Node]

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
        content = try container.decodeContent(forKey: .content)
    }

    public init(nodeType: NodeType, content: [Node]) {
        self.nodeType = nodeType
        self.content = content
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encodeNodes(content, forKey: .content)
    }
}

/// The top level node which contains all other nodes.
/// @objc declaration, NSObject inheritance, and NSCoding conformance
/// are required so `RichTextDocument` can be used as a
/// transformable Core Data field.
@objc public class RichTextDocument: NSObject, RecursiveNode, NSCoding {
    public let nodeType: NodeType
    public internal(set) var content: [Node]

    public init(content: [Node]) {
        self.content = PharmaNodePreprocessor.preprocessedContent(content: content)
        self.nodeType = .document
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
        let content = try container.decodeContent(forKey: .content)
        self.content = PharmaNodePreprocessor.preprocessedContent(content: content)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encodeNodes(content, forKey: .content)
    }

    public func encode(with aCoder: NSCoder) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        aCoder.encode(data)
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let data = aDecoder.decodeData() else {
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(RichTextDocument.self, from: data)
            self.content = decoded.content
            self.nodeType = .document
        } catch {
            print(error)
            return nil
        }
    }
}

/// A block of text, containing child `Text` nodes.
public final class Paragraph: BlockNode {}

public final class NoWrapContainer: BlockNode {}

/// A block representing an unordered list containing list items as its children.
public final class UnorderedList: BlockNode {}

/// A block representing an ordered list containing list items as its children.
public final class OrderedList: BlockNode {}

/// A block representing a block quote.
public final class BlockQuote: BlockNode {}

/// A block representing line break.
public final class LineBreak: NoContentNode {}

/// An item in either an ordered or unordered list.
public final class ListItem: BlockNode {
    public override init(nodeType: NodeType, content: [Node]) {
        super.init(nodeType: nodeType, content: PharmaNodePreprocessor.preprocessedContent(content: content))
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        content = PharmaNodePreprocessor.preprocessedContent(content: content)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

/// A block representing a rule, or break within the content of the document.
public final class HorizontalRule: NoContentNode {}

/// A heading for the document.
public final class Heading: BlockNode {
    /// The level of the heading, between 1 an 6.
    public var level: UInt!

    public init?(level: UInt, content: [Node]) {
        guard let nodeType: NodeType = {
            switch level {
            case 1: return .h1
            case 2: return .h2
            case 3: return .h3
            case 4: return .h4
            case 5: return .h5
            case 6: return .h6
            default: return nil
            }
        }() else { return nil }
        super.init(nodeType: nodeType, content: content)
    }

    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        switch nodeType {
        case .h1: level = 1
        case .h2: level = 2
        case .h3: level = 3
        case .h4: level = 4
        case .h5: level = 5
        case .h6: level = 6
        default: fatalError("A serious error occured, attempted to initialize a Heading with an invalid heading level")
        }
    }
}

/// A hyperlink with a title and URI.
public class Hyperlink: InlineNode {

    /// The title text and URI for the hyperlink.
    public let data: Hyperlink.Data

    /// A container for the title text and URI of a hyperlink.
    public struct Data: Codable {
        /// The URI which the hyperlink links to.
        public let uri: String
        /// The text which should be displayed for the hyperlink.
        public let title: String?

        public init(uri: String, title: String?) {
            self.uri = uri
            self.title = title
        }
    }

    public init(data: Hyperlink.Data, content: [Node]) {
        self.data = data
        super.init(nodeType: .hyperlink, content: content)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(data, forKey: .data)
        try container.encodeNodes(content, forKey: .content)
    }
}

/// A node containing text with marks.
public struct Text: Node, Equatable {
    public let nodeType: NodeType

    /// The string value of the text.
    public let value: String
    /// An array of the markup styles which should be applied to the text.
    public let marks: [Mark]? // Pharma Rich Text: Unlike Contenful's specifications. In Pharma a text node can be without marks. So `marks` array needs to be optional.

    public init(value: String, marks: [Mark]) {
        self.nodeType = .text
        self.value = value
        self.marks = marks
    }

    /// THe markup styling which should be applied to the text.
    public struct Mark: Codable, Equatable {
        public let type: MarkType

        public init(type: MarkType) {
            self.type = type
        }
    }

    /// A type of the markup styling which should be applied to the text.
    public enum MarkType: String, Codable, Equatable {
        /// Bold text.
        case bold
        /// Italicized text.
        case italic
        /// Underlined text.
        case underline
        /// Text formatted as code; presumably with monospaced font.
        case code
    }
}

// MARK: - Pharma Nodes

public class Phrasionary: InlineNode {
    
    public let data: Phrasionary.Data
    
    public struct Data: Codable {
        public let phraseGroupEid: String
        
        public init(phraseGroupEid: String) {
            self.phraseGroupEid = phraseGroupEid
        }
    }
    
    public init(data: Phrasionary.Data, content: [Node]) {
        self.data = data
        super.init(nodeType: .phrasionary, content: content)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(data, forKey: .data)
        try container.encodeNodes(content, forKey: .content)
    }
}

public class AmbossLink: InlineNode {

    /// The title text and URI for the hyperlink.
    public let data: AmbossLink.Data

    /// A container for the title text and URI of a hyperlink.
    public struct Data: Codable {

        // `anchor` and `articleEid` are nil in case linkType == "hyperlink"
        // In this case the uri will be a fully qualified URL
        // Example:
        // nodeType -> link && linkType -> hyperlink
        // https://www.embryotox.de/arzneimittel/details/ansicht/medikament/amoxicillin
        /*
        {
          "anchor": "pc_adult_pregnancy",
          "__typename": "PocketCardSection",
          "content": "{\"nodeType\":\"document\",\"content\":[{\"nodeType\":\"link\",\"data\":{\"linkType\":\"hyperlink\",\"uri\":\"https://www.embryotox.de/arzneimittel/details/ansicht/medikament/amoxicillin\"},\"content\":[{\"nodeType\":\"text\",\"value\":\"Embryotox\"}]}]}",
          "title": "Schwangerschaft / Stillzeit"
        }
         */
        //
        // In case `anchor` and `articleEid` are not nil
        // the uri will just be a fragment
        // Example:
        // nodeType -> link && linkType -> article
        // article/mm0VTg#Za6dad35eb36b5da0940872cd1193a503
        /*
         {\"nodeType\":\"list-item\",\"content\":[{\"nodeType\":\"phrasionary\",\"data\":{\"phraseGroupEid\":\"ROalHk\"},\"content\":[{\"nodeType\":\"link\",\"data\":{\"anchor\":\"Za6dad35eb36b5da0940872cd1193a503\",\"articleEid\":\"mm0VTg\",\"linkType\":\"article\",\"phraseGroupEid\":\"ROalHk\",\"uri\":\"/article/mm0VTg#Za6dad35eb36b5da0940872cd1193a503\"},\"content\":[{\"nodeType\":\"text\",\"value\":\"Amoxicillin\"}]}]},{\"nodeType\":\"text\",\"value\":\" kann durch \"},{\"nodeType\":\"link\",\"data\":{\"anchor\":\"Z3e6b3e2ba0507a291a9e945e5de0a4e2\",\"articleEid\":\"S50yjg\",\"linkType\":\"article\",\"phraseGroupEid\":\"\",\"uri\":\"/article/S50yjg#Z3e6b3e2ba0507a291a9e945e5de0a4e2\"},\"content\":[{\"nodeType\":\"text\",\"value\":\"Hämodialyse\"}]},{\"nodeType\":\"text\",\"value\":\" aus Kreislauf entfernt werden\"}]}
         */
        public let anchor: String?
        public let articleEid: String?

        public let linkType: String // Either "article" or "hyperlink"
        public let uri: String // Either full URL or fragment


        public init(anchor: String, articleEid: String, linkType: String, uri: String) {
            self.anchor = anchor
            self.articleEid = articleEid
            self.linkType = linkType
            self.uri = uri
        }
    }

    public init(data: AmbossLink.Data, content: [Node]) {
        self.data = data
        super.init(nodeType: .ambossLink, content: content)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(data, forKey: .data)
        try container.encodeNodes(content, forKey: .content)
    }
}

public class Superscript: InlineNode {
    
    public let data: Superscript.Data?

    public struct Data: Codable {
        
    }

    public init(data: Superscript.Data?, content: [Node]) {
        self.data = data
        super.init(nodeType: .superscript, content: content)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeNodes(content, forKey: .content)
    }
}

public class Subscript: InlineNode {
    
    public let data: Subscript.Data?

    public struct Data: Codable {
        
    }

    public init(data: Subscript.Data?, content: [Node]) {
        self.data = data
        super.init(nodeType: .hyperlink, content: content)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeContentCodingKeys.self)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeContentCodingKeys.self)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeNodes(content, forKey: .content)
    }
}

private class PharmaNodePreprocessor {
    /// This methods transforms a list item from Pharma's representation to Contentful's representation so that Contentful's rich text renderer can render it.
    ///
    /// We make some changes to the Pharma list items and document nodes so they are compatible with the way Contentful renderer works.
    ///
    /// 1- The content array of a list item in Contentful needs to have one item only that is a paragraph. So we wrap the Pharma list item content inside a paragraph.
    /// 2- Contenful won't apply list stying to a paragraph whose content array contains a nested list. Hence, a Contentful nested list should not have sibling nodes.
    ///
    /// To solve this we wrap:
    /// - Each list inside a paragraph
    /// - The other nodes that are adjacent to each other in paragraphs
    ///
    /// To achieve that:
    /// - We get the lists indices in the content array
    /// - We divide the content array into subarrays based on the indices we found (each list is going to be the only member of its array). For example we have 4 members: [Text, Text, List, Phrasionary, Text], the resulting array will be: [[Text, Text], [List], [Phrasionary, Text]]
    /// - We wrap each subarray in a paragraph
    ///
    /// - Parameter content: The original Pharma content.
    /// - Returns: Pharma content after preprocessing it and wrapping it inside a `Paragraph`.
    static func preprocessedContent(content: [Node]) -> [Node] {
        var processedContent: [Node]
        if content.contains(where: { Self.isList(node: $0) }) {
            let listIndices = content.enumerated().compactMap { Self.isList(node: $0.element) ? $0.offset : nil }
            let splitContent = content.subarrays(indices: listIndices)
            
            processedContent = splitContent
                .map {
                    Paragraph(nodeType: .paragraph, content: $0)
                }
        } else {
            processedContent = content
        }
        
        let result = [Paragraph(nodeType: .paragraph, content: processedContent)]
        
        return result
    }
    
    private static func isList(node: Node) -> Bool {
        node is UnorderedList || node is OrderedList
    }
}

private extension KeyedDecodingContainer {

    func decodeContent(forKey key: K) throws -> [Node] {

        // A copy as an array of dictionaries just to extract "nodeType" field.
        guard let jsonContent = try decode(Swift.Array<Any>.self, forKey: key) as? [[String: Any]] else {
            throw SDKError.unparseableJSON(data: nil, errorMessage: "SDK was unable to serialize returned resources")
        }

        var contentJSONContainer = try nestedUnkeyedContainer(forKey: key)
        var content: [Node] = []

        while !contentJSONContainer.isAtEnd {
            guard let nodeType = jsonContent.nodeType(at: contentJSONContainer.currentIndex) else {
                let errorMessage = "SDK was unable to parse nodeType property necessary to finish resource serialization."
                throw SDKError.unparseableJSON(data: nil, errorMessage: errorMessage)
            }
            let element = try nodeType.type.popNodeDecodable(from: &contentJSONContainer)
            content.append(element)
        }
        return content
    }
}

// MARK: - Private Extensions

private extension KeyedEncodingContainer {
    mutating func encodeNodes(_ nodes: [Node], forKey key: K) throws {
        var contentContainer = nestedUnkeyedContainer(forKey: key)
        try nodes.forEach { node in
            try contentContainer.encode(AnyEncodable(value: node))
        }
    }
}

/// This wrapper allows arbitrary objects or structs conforming to `Node`
/// to be encoded _without_ casting to their static types.
/// See http://yourfriendlyioscoder.com/blog/2019/04/27/any-encodable/
private struct AnyEncodable: Encodable {
    let value: Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

private extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}
