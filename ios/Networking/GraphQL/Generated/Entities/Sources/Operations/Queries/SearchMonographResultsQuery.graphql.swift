// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchMonographResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchMonographResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchMonographResults($query: String!, $first: Int!, $after: String) { searchAmbossSubstanceResults( query: $query first: $first after: $after compact: true ) { __typename totalCount pageInfo { endCursor hasNextPage __typename } edges { __typename cursor node { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields } } } } } } }"#,
      fragments: [AmbossSubstanceNodeFields.self]
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
      .field("searchAmbossSubstanceResults", SearchAmbossSubstanceResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "after": .variable("after"),
        "compact": true
      ]),
    ] }

    public var searchAmbossSubstanceResults: SearchAmbossSubstanceResults { __data["searchAmbossSubstanceResults"] }

    /// SearchAmbossSubstanceResults
    ///
    /// Parent Type: `SearchResultAmbossSubstanceNodeConnection`
    public struct SearchAmbossSubstanceResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeConnection }
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

      /// SearchAmbossSubstanceResults.PageInfo
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

      /// SearchAmbossSubstanceResults.Edge
      ///
      /// Parent Type: `SearchResultAmbossSubstanceNodeEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination
        public var cursor: String { __data["cursor"] }
        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchAmbossSubstanceResults.Edge.Node
        ///
        /// Parent Type: `SearchResultAmbossSubstanceNode`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("children", [Child].self),
            .fragment(AmbossSubstanceNodeFields.self),
          ] }

          /// List of child Nodes.
          public var children: [Child] { __data["children"] }
          /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var title: String { __data["title"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
          public var target: Target { __data["target"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
          }

          /// SearchAmbossSubstanceResults.Edge.Node.Child
          ///
          /// Parent Type: `SearchResultAmbossSubstanceNode`
          public struct Child: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("children", [Child].self),
              .fragment(AmbossSubstanceNodeFields.self),
            ] }

            /// List of child Nodes.
            public var children: [Child] { __data["children"] }
            /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var title: String { __data["title"] }
            /// List of details. Can contain \<b\>, \<i\> HTML tags.
            public var details: [String?]? { __data["details"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
            /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
            public var target: Target { __data["target"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
            }

            /// SearchAmbossSubstanceResults.Edge.Node.Child.Child
            ///
            /// Parent Type: `SearchResultAmbossSubstanceNode`
            public struct Child: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("children", [Child].self),
                .fragment(AmbossSubstanceNodeFields.self),
              ] }

              /// List of child Nodes.
              public var children: [Child] { __data["children"] }
              /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var title: String { __data["title"] }
              /// List of details. Can contain \<b\>, \<i\> HTML tags.
              public var details: [String?]? { __data["details"] }
              /// Unique ID for tracking and analytics.
              public var _trackingUuid: String { __data["_trackingUuid"] }
              /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
              public var target: Target { __data["target"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
              }

              /// SearchAmbossSubstanceResults.Edge.Node.Child.Child.Child
              ///
              /// Parent Type: `SearchResultAmbossSubstanceNode`
              public struct Child: KnowledgeGraphQLEntities.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(AmbossSubstanceNodeFields.self),
                ] }

                /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var title: String { __data["title"] }
                /// List of details. Can contain \<b\>, \<i\> HTML tags.
                public var details: [String?]? { __data["details"] }
                /// Unique ID for tracking and analytics.
                public var _trackingUuid: String { __data["_trackingUuid"] }
                /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
                public var target: Target { __data["target"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
                }

                public typealias Target = AmbossSubstanceNodeFields.Target
              }

              public typealias Target = AmbossSubstanceNodeFields.Target
            }

            public typealias Target = AmbossSubstanceNodeFields.Target
          }

          public typealias Target = AmbossSubstanceNodeFields.Target
        }
      }
    }
  }
}
