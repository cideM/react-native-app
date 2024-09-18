// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchGuidelineResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchGuidelineResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchGuidelineResults($query: String!, $first: Int!, $after: String) { searchGuidelineResults(query: $query, first: $first, after: $after) { __typename pageInfo { __typename hasNextPage endCursor } edges { __typename node { __typename metadata title labels subtitle subtitle details _trackingUuid secondaryTargets { __typename title body _trackingUuid } target { __typename externalUrl _trackingUuid } } } totalCount } }"#
    ))

  public var query: String
  public var first: Int
  public var after: GraphQLNullable<String>

  public init(
    query: String,
    first: Int,
    after: GraphQLNullable<String>
  ) {
    self.query = query
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "query": query,
    "first": first,
    "after": after
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchGuidelineResults", SearchGuidelineResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }

    public var searchGuidelineResults: SearchGuidelineResults { __data["searchGuidelineResults"] }

    /// SearchGuidelineResults
    ///
    /// Parent Type: `SearchResultGuidelinesConnection`
    public struct SearchGuidelineResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
        .field("totalCount", Int.self),
      ] }

      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }
      /// Number of results
      public var totalCount: Int { __data["totalCount"] }

      /// SearchGuidelineResults.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// SearchGuidelineResults.Edge
      ///
      /// Parent Type: `SearchResultGuidelinesEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node?.self),
        ] }

        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchGuidelineResults.Edge.Node
        ///
        /// Parent Type: `SearchResultGuideline`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuideline }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("labels", [String?]?.self),
            .field("subtitle", String?.self),
            .field("details", [String?]?.self),
            .field("_trackingUuid", String.self),
            .field("secondaryTargets", [SecondaryTarget?]?.self),
            .field("target", Target?.self),
          ] }

          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          /// List of labels. For example: vorklinik, klinik, arzt.
          public var labels: [String?]? { __data["labels"] }
          /// Subtitle of the Search Result. Should be considered part of the label for the main target and exhibit the same behavior as the title on clients. Can contain \<b\>, \<i\> HTML tags.
          public var subtitle: String? { __data["subtitle"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// List of secondary AMBOSS targets with titles.
          public var secondaryTargets: [SecondaryTarget?]? { __data["secondaryTargets"] }
          public var target: Target? { __data["target"] }

          /// SearchGuidelineResults.Edge.Node.SecondaryTarget
          ///
          /// Parent Type: `SecondaryTarget`
          public struct SecondaryTarget: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SecondaryTarget }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
              .field("body", String?.self),
              .field("_trackingUuid", String.self),
            ] }

            /// The title of the target.Can contain \<b\>, \<i\> HTML tags.
            public var title: String { __data["title"] }
            /// Usually a text content of the search result.Can contain \<b\>, \<i\> HTML tags.
            public var body: String? { __data["body"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }

          /// SearchGuidelineResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetExternalUrl`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetExternalUrl }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("externalUrl", String.self),
              .field("_trackingUuid", String.self),
            ] }

            /// The URL of the external resource.
            public var externalUrl: String { __data["externalUrl"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }
    }
  }
}
