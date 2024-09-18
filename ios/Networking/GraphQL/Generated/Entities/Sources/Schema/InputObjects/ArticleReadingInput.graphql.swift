// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ArticleReadingInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    articleEid: EncodedId,
    createdAt: GraphQLNullable<DateTime> = nil,
    timeSpent: GraphQLNullable<Int> = nil
  ) {
    __data = InputDict([
      "articleEid": articleEid,
      "createdAt": createdAt,
      "timeSpent": timeSpent
    ])
  }

  public var articleEid: EncodedId {
    get { __data["articleEid"] }
    set { __data["articleEid"] = newValue }
  }

  public var createdAt: GraphQLNullable<DateTime> {
    get { __data["createdAt"] }
    set { __data["createdAt"] = newValue }
  }

  /// Seconds spent in the reading
  public var timeSpent: GraphQLNullable<Int> {
    get { __data["timeSpent"] }
    set { __data["timeSpent"] = newValue }
  }
}
