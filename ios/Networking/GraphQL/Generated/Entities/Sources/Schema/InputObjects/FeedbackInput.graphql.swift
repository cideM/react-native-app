// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct FeedbackInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    message: String,
    intention: GraphQLNullable<GraphQLEnum<FeedbackIntentionType>> = nil,
    type: GraphQLNullable<GraphQLEnum<FeedbackType>> = nil,
    source: FeedbackSource,
    mobileInfo: GraphQLNullable<FeedbackMobileInfo> = nil
  ) {
    __data = InputDict([
      "message": message,
      "intention": intention,
      "type": type,
      "source": source,
      "mobileInfo": mobileInfo
    ])
  }

  public var message: String {
    get { __data["message"] }
    set { __data["message"] = newValue }
  }

  /// User-based pre-categorization – either intention OR type needs to be present
  public var intention: GraphQLNullable<GraphQLEnum<FeedbackIntentionType>> {
    get { __data["intention"] }
    set { __data["intention"] = newValue }
  }

  /// Feedback quality/mood – use intention instead and expect deprecation
  public var type: GraphQLNullable<GraphQLEnum<FeedbackType>> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }

  public var source: FeedbackSource {
    get { __data["source"] }
    set { __data["source"] = newValue }
  }

  public var mobileInfo: GraphQLNullable<FeedbackMobileInfo> {
    get { __data["mobileInfo"] }
    set { __data["mobileInfo"] = newValue }
  }
}
