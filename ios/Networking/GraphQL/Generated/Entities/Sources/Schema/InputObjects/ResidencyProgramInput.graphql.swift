// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Only one of the two fields can be provided
public struct ResidencyProgramInput: InputObject {
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

  /// Free-text if the residency program is not found
  public var text: GraphQLNullable<String> {
    get { __data["text"] }
    set { __data["text"] = newValue }
  }
}
