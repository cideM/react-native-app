// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct AmbossSubstanceNodeFields: KnowledgeGraphQLEntities.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ambossSubstanceNodeFields on SearchResultAmbossSubstanceNode { __typename title details _trackingUuid target { __typename ambossSubstanceId anchorId _trackingUuid } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("title", String.self),
    .field("details", [String?]?.self),
    .field("_trackingUuid", String.self),
    .field("target", Target.self),
  ] }

  /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
  public var title: String { __data["title"] }
  /// List of details. Can contain \<b\>, \<i\> HTML tags.
  public var details: [String?]? { __data["details"] }
  /// Unique ID for tracking and analytics.
  public var _trackingUuid: String { __data["_trackingUuid"] }
  /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
  public var target: Target { __data["target"] }

  /// Target
  ///
  /// Parent Type: `SearchTargetAmbossSubstanceNode`
  public struct Target: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetAmbossSubstanceNode }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("ambossSubstanceId", String.self),
      .field("anchorId", String?.self),
      .field("_trackingUuid", String.self),
    ] }

    /// AMBOSS Substance ID.
    public var ambossSubstanceId: String { __data["ambossSubstanceId"] }
    /// Anchor ID.
    public var anchorId: String? { __data["anchorId"] }
    /// Unique ID for tracking and analytics.
    public var _trackingUuid: String { __data["_trackingUuid"] }
  }
}
