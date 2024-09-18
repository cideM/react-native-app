// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ArticleInteractionsQuery: GraphQLQuery {
  public static let operationName: String = "ArticleInteractions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ArticleInteractions($first: Int!, $after: String) { currentUser { __typename articleInteractions(first: $first, after: $after) { __typename pageInfo { __typename endCursor hasNextPage } edges { __typename node { __typename eid type active updatedAt articleEid } } } } }"#
    ))

  public var first: Int
  public var after: GraphQLNullable<String>

  public init(
    first: Int,
    after: GraphQLNullable<String>
  ) {
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "first": first,
    "after": after
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentUser", CurrentUser.self),
    ] }

    /// Current authorized user
    public var currentUser: CurrentUser { __data["currentUser"] }

    /// CurrentUser
    ///
    /// Parent Type: `User`
    public struct CurrentUser: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("articleInteractions", ArticleInteractions?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// Latest user interactions in articles
      public var articleInteractions: ArticleInteractions? { __data["articleInteractions"] }

      /// CurrentUser.ArticleInteractions
      ///
      /// Parent Type: `ArticleInteractionConnection`
      public struct ArticleInteractions: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ArticleInteractionConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// CurrentUser.ArticleInteractions.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("endCursor", String?.self),
            .field("hasNextPage", Bool.self),
          ] }

          public var endCursor: String? { __data["endCursor"] }
          public var hasNextPage: Bool { __data["hasNextPage"] }
        }

        /// CurrentUser.ArticleInteractions.Edge
        ///
        /// Parent Type: `ArticleInteractionEdge`
        public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ArticleInteractionEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// CurrentUser.ArticleInteractions.Edge.Node
          ///
          /// Parent Type: `ArticleInteraction`
          public struct Node: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ArticleInteraction }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("eid", KnowledgeGraphQLEntities.ID.self),
              .field("type", GraphQLEnum<KnowledgeGraphQLEntities.ArticleInteractionType>.self),
              .field("active", Bool.self),
              .field("updatedAt", String.self),
              .field("articleEid", KnowledgeGraphQLEntities.ID.self),
            ] }

            public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
            public var type: GraphQLEnum<KnowledgeGraphQLEntities.ArticleInteractionType> { __data["type"] }
            public var active: Bool { __data["active"] }
            /// ISO formated Date. Example: 2022-02-15T00:00:00+0000
            public var updatedAt: String { __data["updatedAt"] }
            public var articleEid: KnowledgeGraphQLEntities.ID { __data["articleEid"] }
          }
        }
      }
    }
  }
}
