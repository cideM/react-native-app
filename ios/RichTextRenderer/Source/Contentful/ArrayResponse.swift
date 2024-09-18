//
//  ArrayResponse.swift
//  Contentful
//
//  Created by Boris Bügling on 18/08/15.
//  Copyright © 2015 Contentful GmbH. All rights reserved.
//

// Convenience method for grabbing the content type information of a json item in an array of resources.
internal extension Swift.Array where Element == Dictionary<String, Any> {

    func nodeType(at index: Int) -> NodeType? {
        guard let nodeTypeString = self[index]["nodeType"] as? String, let nodeType = NodeType(rawValue: nodeTypeString) else {
            return nil
        }
        return nodeType
    }
}
