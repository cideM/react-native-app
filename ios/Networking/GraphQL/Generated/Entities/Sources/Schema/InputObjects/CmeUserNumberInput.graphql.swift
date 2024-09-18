// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CmeUserNumberInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    number: GraphQLNullable<String> = nil,
    type: GraphQLNullable<GraphQLEnum<CmeType>> = nil
  ) {
    __data = InputDict([
      "number": number,
      "type": type
    ])
  }

  public var number: GraphQLNullable<String> {
    get { __data["number"] }
    set { __data["number"] = newValue }
  }

  public var type: GraphQLNullable<GraphQLEnum<CmeType>> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }
}
