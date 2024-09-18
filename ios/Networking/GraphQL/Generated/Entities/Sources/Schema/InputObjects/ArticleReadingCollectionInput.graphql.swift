// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ArticleReadingCollectionInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    articleReadings: [ArticleReadingInput?],
    referrer: GraphQLEnum<ArticleReferrer>
  ) {
    __data = InputDict([
      "articleReadings": articleReadings,
      "referrer": referrer
    ])
  }

  public var articleReadings: [ArticleReadingInput?] {
    get { __data["articleReadings"] }
    set { __data["articleReadings"] = newValue }
  }

  public var referrer: GraphQLEnum<ArticleReferrer> {
    get { __data["referrer"] }
    set { __data["referrer"] = newValue }
  }
}
