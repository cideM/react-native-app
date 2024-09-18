// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct SearchFiltersMediaInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    mediaType: GraphQLNullable<[String]> = nil
  ) {
    __data = InputDict([
      "mediaType": mediaType
    ])
  }

  /// Values of the filters to apply on Media type.
  public var mediaType: GraphQLNullable<[String]> {
    get { __data["mediaType"] }
    set { __data["mediaType"] = newValue }
  }
}
