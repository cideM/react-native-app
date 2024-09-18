// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchArticleResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchArticleResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchArticleResults($query: String!, $first: Int!, $after: String) { searchArticleContentTree( query: $query first: $first after: $after compact: true ) { __typename totalCount pageInfo { __typename endCursor hasNextPage } edges { __typename cursor node { __typename ...articleNodeFields children { __typename ...articleNodeFields children { __typename ...articleNodeFields children { __typename ...articleNodeFields } } } } } } }"#,
      fragments: [ArticleNodeFields.self]
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
      .field("searchArticleContentTree", SearchArticleContentTree.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "after": .variable("after"),
        "compact": true
      ]),
    ] }

    public var searchArticleContentTree: SearchArticleContentTree { __data["searchArticleContentTree"] }

    /// SearchArticleContentTree
    ///
    /// Parent Type: `SearchResultArticleNodeConnection`
    public struct SearchArticleContentTree: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("totalCount", Int.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
      ] }

      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }

      /// SearchArticleContentTree.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("endCursor", String?.self),
          .field("hasNextPage", Bool.self),
        ] }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
      }

      /// SearchArticleContentTree.Edge
      ///
      /// Parent Type: `SearchResultArticleNodeEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination
        public var cursor: String { __data["cursor"] }
        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchArticleContentTree.Edge.Node
        ///
        /// Parent Type: `SearchResultArticleNode`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("children", [Child].self),
            .fragment(ArticleNodeFields.self),
          ] }

          /// List of child Nodes.
          public var children: [Child] { __data["children"] }
          /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var title: String { __data["title"] }
          /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var snippet: String? { __data["snippet"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
          public var target: Target { __data["target"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var articleNodeFields: ArticleNodeFields { _toFragment() }
          }

          /// SearchArticleContentTree.Edge.Node.Child
          ///
          /// Parent Type: `SearchResultArticleNode`
          public struct Child: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("children", [Child].self),
              .fragment(ArticleNodeFields.self),
            ] }

            /// List of child Nodes.
            public var children: [Child] { __data["children"] }
            /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var title: String { __data["title"] }
            /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var snippet: String? { __data["snippet"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
            /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
            public var target: Target { __data["target"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var articleNodeFields: ArticleNodeFields { _toFragment() }
            }

            /// SearchArticleContentTree.Edge.Node.Child.Child
            ///
            /// Parent Type: `SearchResultArticleNode`
            public struct Child: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("children", [Child].self),
                .fragment(ArticleNodeFields.self),
              ] }

              /// List of child Nodes.
              public var children: [Child] { __data["children"] }
              /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var title: String { __data["title"] }
              /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var snippet: String? { __data["snippet"] }
              /// Unique ID for tracking and analytics.
              public var _trackingUuid: String { __data["_trackingUuid"] }
              /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
              public var target: Target { __data["target"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var articleNodeFields: ArticleNodeFields { _toFragment() }
              }

              /// SearchArticleContentTree.Edge.Node.Child.Child.Child
              ///
              /// Parent Type: `SearchResultArticleNode`
              public struct Child: KnowledgeGraphQLEntities.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(ArticleNodeFields.self),
                ] }

                /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var title: String { __data["title"] }
                /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var snippet: String? { __data["snippet"] }
                /// Unique ID for tracking and analytics.
                public var _trackingUuid: String { __data["_trackingUuid"] }
                /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
                public var target: Target { __data["target"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var articleNodeFields: ArticleNodeFields { _toFragment() }
                }

                public typealias Target = ArticleNodeFields.Target
              }

              public typealias Target = ArticleNodeFields.Target
            }

            public typealias Target = ArticleNodeFields.Target
          }

          public typealias Target = ArticleNodeFields.Target
        }
      }
    }
  }
}
