// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct UserArticleInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    articleEid: ID,
    learned: GraphQLNullable<Bool> = nil,
    favorite: GraphQLNullable<Bool> = nil,
    updatedAt: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "articleEid": articleEid,
      "learned": learned,
      "favorite": favorite,
      "updatedAt": updatedAt
    ])
  }

  public var articleEid: ID {
    get { __data["articleEid"] }
    set { __data["articleEid"] = newValue }
  }

  public var learned: GraphQLNullable<Bool> {
    get { __data["learned"] }
    set { __data["learned"] = newValue }
  }

  public var favorite: GraphQLNullable<Bool> {
    get { __data["favorite"] }
    set { __data["favorite"] = newValue }
  }

  /// Client date when the change happened
  public var updatedAt: GraphQLNullable<String> {
    get { __data["updatedAt"] }
    set { __data["updatedAt"] = newValue }
  }
}
