// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct FeedbackSource: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    type: GraphQLEnum<FeedbackSourceType>,
    id: GraphQLNullable<String> = nil,
    version: GraphQLNullable<Int> = nil
  ) {
    __data = InputDict([
      "type": type,
      "id": id,
      "version": version
    ])
  }

  public var type: GraphQLEnum<FeedbackSourceType> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }

  public var id: GraphQLNullable<String> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  public var version: GraphQLNullable<Int> {
    get { __data["version"] }
    set { __data["version"] = newValue }
  }
}
