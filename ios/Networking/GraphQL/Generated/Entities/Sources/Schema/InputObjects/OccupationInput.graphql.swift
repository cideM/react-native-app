// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Only one of two fields can be provided
public struct OccupationInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: GraphQLNullable<ID> = nil,
    text: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "id": id,
      "text": text
    ])
  }

  /// Id from the reference
  public var id: GraphQLNullable<ID> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  /// Free-text occupation info
  public var text: GraphQLNullable<String> {
    get { __data["text"] }
    set { __data["text"] = newValue }
  }
}
