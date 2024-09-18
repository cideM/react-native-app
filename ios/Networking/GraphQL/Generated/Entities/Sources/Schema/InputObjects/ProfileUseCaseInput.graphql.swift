// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ProfileUseCaseInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: GraphQLNullable<EncodedId> = nil,
    text: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "id": id,
      "text": text
    ])
  }

  /// Id from the reference
  public var id: GraphQLNullable<EncodedId> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }

  /// Free-text use case info
  public var text: GraphQLNullable<String> {
    get { __data["text"] }
    set { __data["text"] = newValue }
  }
}
