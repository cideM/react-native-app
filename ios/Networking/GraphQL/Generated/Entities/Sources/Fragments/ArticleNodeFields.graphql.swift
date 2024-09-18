// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ArticleNodeFields: KnowledgeGraphQLEntities.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment articleNodeFields on SearchResultArticleNode { __typename title snippet _trackingUuid target { __typename articleEid sectionEid nodeId _trackingUuid } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("title", String.self),
    .field("snippet", String?.self),
    .field("_trackingUuid", String.self),
    .field("target", Target.self),
  ] }

  /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
  public var title: String { __data["title"] }
  /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
  public var snippet: String? { __data["snippet"] }
  /// Unique ID for tracking and analytics.
  public var _trackingUuid: String { __data["_trackingUuid"] }
  /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
  public var target: Target { __data["target"] }

  /// Target
  ///
  /// Parent Type: `SearchTargetArticleNode`
  public struct Target: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetArticleNode }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("articleEid", String.self),
      .field("sectionEid", String?.self),
      .field("nodeId", String?.self),
      .field("_trackingUuid", String.self),
    ] }

    /// Article EID.
    public var articleEid: String { __data["articleEid"] }
    /// Section EID.
    public var sectionEid: String? { __data["sectionEid"] }
    /// Node ID.
    public var nodeId: String? { __data["nodeId"] }
    /// Unique ID for tracking and analytics.
    public var _trackingUuid: String { __data["_trackingUuid"] }
  }
}
