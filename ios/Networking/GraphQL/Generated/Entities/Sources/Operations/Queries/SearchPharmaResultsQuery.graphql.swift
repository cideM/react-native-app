// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchPharmaResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchPharmaResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchPharmaResults($query: String!, $first: Int!, $after: String) { searchPharmaAgentResults(query: $query, first: $first, after: $after) { __typename didYouMean totalCount pageInfo { __typename hasNextPage endCursor } edges { __typename cursor node { __typename metadata title subtitle details _trackingUuid target { __typename pharmaAgentId drugId _trackingUuid } } } } }"#
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
      .field("searchPharmaAgentResults", SearchPharmaAgentResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }

    public var searchPharmaAgentResults: SearchPharmaAgentResults { __data["searchPharmaAgentResults"] }

    /// SearchPharmaAgentResults
    ///
    /// Parent Type: `SearchResultPharmaAgentsConnection`
    public struct SearchPharmaAgentResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("didYouMean", String?.self),
        .field("totalCount", Int.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
      ] }

      /// Autocorrection of the submitted query, if applied for search.
      public var didYouMean: String? { __data["didYouMean"] }
      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }

      /// SearchPharmaAgentResults.PageInfo
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

      /// SearchPharmaAgentResults.Edge
      ///
      /// Parent Type: `SearchResultPharmaAgentsEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination
        public var cursor: String { __data["cursor"] }
        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchPharmaAgentResults.Edge.Node
        ///
        /// Parent Type: `SearchResultPharmaAgent`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgent }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("subtitle", String?.self),
            .field("details", [String?]?.self),
            .field("_trackingUuid", String.self),
            .field("target", Target.self),
          ] }

          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          /// Subtitle of the Search Result. Should be considered part of the label for the main target and exhibit the same behavior as the title on clients. Can contain \<b\>, \<i\> HTML tags.
          public var subtitle: String? { __data["subtitle"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Pharma Agent target.
          public var target: Target { __data["target"] }

          /// SearchPharmaAgentResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetPharmaAgent`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetPharmaAgent }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pharmaAgentId", String.self),
              .field("drugId", String.self),
              .field("_trackingUuid", String.self),
            ] }

            /// Pharma Agent ID.
            public var pharmaAgentId: String { __data["pharmaAgentId"] }
            /// Drug ID.
            public var drugId: String { __data["drugId"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }
    }
  }
}
