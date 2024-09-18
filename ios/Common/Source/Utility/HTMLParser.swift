//
//  NSMutableAttributedString+lightweightHtmlParsing.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 11.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import libxml2
import UIKit

enum ParsedHtmlDocument {}

private extension ParsedHtmlDocument.Node {
    init?(_ htmlString: String) {
        guard let documentData = htmlString.data(using: .utf8), let document = documentData.withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) -> htmlDocPtr? in
            guard let baseAddress = pointer.baseAddress, pointer.isEmpty == false else { return nil }
            let pointer = baseAddress.assumingMemoryBound(to: Int8.self)
            return htmlReadMemory(pointer, Int32(documentData.count), "", nil, Int32(HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue))
        }) else {
            return nil
        }
        node = document.pointee.children.pointee.parent.pointee
    }
}

private extension ParsedHtmlDocument {
    struct Node {
        let node: xmlNode

        var children: [Node] {
            var children: [Node] = []
            var currentNode: xmlNodePtr? = node.children
            while let node = currentNode {
                children.append(Node(node: node.pointee))
                currentNode = node.pointee.next
            }
            return children
        }

        var content: String? {
            guard node.content != nil else { return nil }
            return String(cString: UnsafePointer(node.content))
        }

        var name: String? {
            guard node.name != nil else { return nil }
            return String(cString: UnsafePointer(node.name))
        }

        var isEntityRef: Bool {
            node.type == XML_ENTITY_REF_NODE
        }

        var isElement: Bool {
            node.type == XML_ELEMENT_NODE
        }

        var attributeNodes: [AttributeNode] {
            guard node.properties != nil else { return [] }

            var nodes: [AttributeNode] = []
            var currentNode: xmlAttrPtr? = node.properties
            while let node = currentNode {
                nodes.append(AttributeNode(node: node.pointee))
                currentNode = node.pointee.next
            }
            return nodes
        }
    }
    struct AttributeNode {
        let node: xmlAttr

        var name: String? {
            guard node.name != nil else { return nil }
            return String(cString: UnsafePointer(node.name))
        }

        var value: String? {
            guard let child = node.children else { return nil }
            return Node(node: child.pointee).content
        }
    }
}

public enum HTMLParser {

    public struct Attributes {
        public let normal: [NSAttributedString.Key: Any]?
        public let bold: [NSAttributedString.Key: Any]?
        public let italic: [NSAttributedString.Key: Any]?

        public init(normal: [NSAttributedString.Key: Any]? = nil, bold: [NSAttributedString.Key: Any]? = nil, italic: [NSAttributedString.Key: Any]? = nil) {
            self.normal = normal
            self.bold = bold
            self.italic = italic
        }
    }

    public enum Error: Swift.Error {
        case parsingFailed(html: String)
    }

    static let multipleSpacesRegex = try! NSRegularExpression(pattern: "  +", options: .caseInsensitive) // swiftlint:disable:this force_try

    public static func attributedStringFromHTML(htmlString: String, with style: Attributes? = nil) throws -> NSMutableAttributedString {
        if htmlString.isEmpty {
            return NSMutableAttributedString(string: "")
        }
        guard let node = ParsedHtmlDocument.Node(htmlString) else {
            throw Error.parsingFailed(html: htmlString)
        }

        return attributedString(from: node, with: style).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func attributedString(from node: ParsedHtmlDocument.Node, with style: Attributes?) -> NSMutableAttributedString {
        let nodeAttributedString = NSMutableAttributedString()

        if let content = node.content, !node.isEntityRef, !node.isElement {
            var string = content
            string = string.replacingOccurrences(of: "\r", with: " ")
            string = string.replacingOccurrences(of: "\n", with: " ")
            string = string.replacingOccurrences(of: "\t", with: " ")

            string = multipleSpacesRegex.stringByReplacingMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string), withTemplate: " ")

            let normalAttributedString = NSAttributedString(string: string)
            nodeAttributedString.append(normalAttributedString)
        }

        // Handle children
        for child in node.children {
            let childString = self.attributedString(from: child, with: style)
            nodeAttributedString.append(childString)
        }

        // handle tags
        if node.isElement {
            // Build dictionary to store attributes
            let attributeDictionary = node.attributeNodes.reduce(into: [:]) { $0[$1.name?.lowercased() ?? ""] = $1.value ?? "" }

            switch node.name {
            case "div", "p":
                if !nodeAttributedString.string.hasSuffix("\n") {
                    nodeAttributedString.append(NSAttributedString(string: "\n"))
                }

            case "a":
                if let link = attributeDictionary["href"] {
                    let attributes = [NSAttributedString.Key.link: link]
                    let range = NSRange(nodeAttributedString.string.startIndex..., in: nodeAttributedString.string)
                    nodeAttributedString.addAttributes(attributes, range: range)
                }

            case "b":
                if let attributes = style?.bold {
                    let range = NSRange(nodeAttributedString.string.startIndex..., in: nodeAttributedString.string)
                    nodeAttributedString.addAttributes(attributes, range: range)
                }

            case "i":
                if let attributes = style?.italic {
                    let range = NSRange(nodeAttributedString.string.startIndex..., in: nodeAttributedString.string)
                    nodeAttributedString.addAttributes(attributes, range: range)
                }

            case "br":
                nodeAttributedString.append(NSAttributedString(string: "\n"))

            default:
                break
            }
        }

        // WORKAROUND:
        // Applying the default font here to anything that is not styled already
        // The default font can not be just applied on top of the whole string range
        // cause it would override all other attributes
        if let attributes = style?.normal {
            let range = NSRange(nodeAttributedString.string.startIndex..., in: nodeAttributedString.string)
            nodeAttributedString.enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired) { attr, range, _ in
                if attr.keys.isEmpty {
                    nodeAttributedString.addAttributes(attributes, range: range)
                }
            }
        }

        return nodeAttributedString
    }
}
