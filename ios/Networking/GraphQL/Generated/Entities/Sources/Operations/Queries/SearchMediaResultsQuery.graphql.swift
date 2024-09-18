// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchMediaResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchMediaResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchMediaResults($query: String!, $filters: SearchFiltersMediaInput, $first: Int!, $after: String) { searchMediaResults( query: $query filters: $filters first: $first after: $after ) { __typename pageInfo { __typename hasNextPage endCursor } edges { __typename node { __typename _trackingUuid metadata title mediaType { __typename category label } target { __typename mediaEid assetUrl externalAdditionType externalAdditionUrl _trackingUuid } } } totalCount filters { __typename mediaType { __typename value label matchingCount isActive } } } }"#
    ))

  public var query: String
  public var filters: GraphQLNullable<SearchFiltersMediaInput>
  public var first: Int
  public var after: GraphQLNullable<String>

  public init(
    query: String,
    filters: GraphQLNullable<SearchFiltersMediaInput>,
    first: Int,
    after: GraphQLNullable<String>
  ) {
    self.query = query
    self.filters = filters
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "query": query,
    "filters": filters,
    "first": first,
    "after": after
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchMediaResults", SearchMediaResults.self, arguments: [
        "query": .variable("query"),
        "filters": .variable("filters"),
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }

    public var searchMediaResults: SearchMediaResults { __data["searchMediaResults"] }

    /// SearchMediaResults
    ///
    /// Parent Type: `SearchResultMediaConnection`
    public struct SearchMediaResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
        .field("totalCount", Int.self),
        .field("filters", Filters.self),
      ] }

      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }
      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      /// Media filters applied and/or suggested for the query.
      public var filters: Filters { __data["filters"] }

      /// SearchMediaResults.PageInfo
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

      /// SearchMediaResults.Edge
      ///
      /// Parent Type: `SearchResultMediaEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node?.self),
        ] }

        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchMediaResults.Edge.Node
        ///
        /// Parent Type: `SearchResultMedia`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMedia }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("_trackingUuid", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("mediaType", MediaType.self),
            .field("target", Target.self),
          ] }

          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          public var mediaType: MediaType { __data["mediaType"] }
          public var target: Target { __data["target"] }

          /// SearchMediaResults.Edge.Node.MediaType
          ///
          /// Parent Type: `SearchResultMediaType`
          public struct MediaType: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaType }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("category", GraphQLEnum<KnowledgeGraphQLEntities.SearchMediaTypeCategory>.self),
              .field("label", String.self),
            ] }

            /// Generic category of the Media type, to be represented with the appropriate Icon.
            public var category: GraphQLEnum<KnowledgeGraphQLEntities.SearchMediaTypeCategory> { __data["category"] }
            /// Localized text label for the specific Media type.
            public var label: String { __data["label"] }
          }

          /// SearchMediaResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetMedia`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetMedia }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("mediaEid", String.self),
              .field("assetUrl", String.self),
              .field("externalAdditionType", GraphQLEnum<KnowledgeGraphQLEntities.SearchTargetMediaAdditionType>?.self),
              .field("externalAdditionUrl", String?.self),
              .field("_trackingUuid", String.self),
            ] }

            /// Media ID.
            public var mediaEid: String { __data["mediaEid"] }
            /// The source URL of the media asset.
            public var assetUrl: String { __data["assetUrl"] }
            public var externalAdditionType: GraphQLEnum<KnowledgeGraphQLEntities.SearchTargetMediaAdditionType>? { __data["externalAdditionType"] }
            /// The URL to the external addition. Only used if the media is an external addition.
            public var externalAdditionUrl: String? { __data["externalAdditionUrl"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }

      /// SearchMediaResults.Filters
      ///
      /// Parent Type: `SearchFiltersMedia`
      public struct Filters: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchFiltersMedia }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("mediaType", [MediaType].self),
        ] }

        /// List of Media type filters.
        public var mediaType: [MediaType] { __data["mediaType"] }

        /// SearchMediaResults.Filters.MediaType
        ///
        /// Parent Type: `SearchFilterValue`
        public struct MediaType: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchFilterValue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("value", String.self),
            .field("label", String.self),
            .field("matchingCount", Int?.self),
            .field("isActive", Bool.self),
          ] }

          /// Internal identifier of the filter value.
          public var value: String { __data["value"] }
          /// Localized label for the filter value.
          public var label: String { __data["label"] }
          /// Total number of results that match the filter.
          public var matchingCount: Int? { __data["matchingCount"] }
          /// Current state of the filter.
          public var isActive: Bool { __data["isActive"] }
        }
      }
    }
  }
}
