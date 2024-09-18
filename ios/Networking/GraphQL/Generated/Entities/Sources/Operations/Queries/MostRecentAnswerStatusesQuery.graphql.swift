// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MostRecentAnswerStatusesQuery: GraphQLQuery {
  public static let operationName: String = "MostRecentAnswerStatuses"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MostRecentAnswerStatuses($first: Int!, $after: String) { currentUser { __typename email mostRecentAnswerStatuses(first: $first, after: $after) { __typename ... on AnswerStatusConnection { pageInfo { __typename endCursor hasNextPage } edges { __typename node { __typename questionId status } } } } } }"#
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
        .field("email", String?.self),
        .field("mostRecentAnswerStatuses", MostRecentAnswerStatuses.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      public var email: String? { __data["email"] }
      /// Latest answer statuses of this user
      public var mostRecentAnswerStatuses: MostRecentAnswerStatuses { __data["mostRecentAnswerStatuses"] }

      /// CurrentUser.MostRecentAnswerStatuses
      ///
      /// Parent Type: `AnswerStatusesResult`
      public struct MostRecentAnswerStatuses: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.AnswerStatusesResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsAnswerStatusConnection.self),
        ] }

        public var asAnswerStatusConnection: AsAnswerStatusConnection? { _asInlineFragment() }

        /// CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection
        ///
        /// Parent Type: `AnswerStatusConnection`
        public struct AsAnswerStatusConnection: KnowledgeGraphQLEntities.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = MostRecentAnswerStatusesQuery.Data.CurrentUser.MostRecentAnswerStatuses
          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AnswerStatusConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("pageInfo", PageInfo.self),
            .field("edges", [Edge].self),
          ] }

          public var pageInfo: PageInfo { __data["pageInfo"] }
          public var edges: [Edge] { __data["edges"] }

          /// CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection.PageInfo
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

          /// CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection.Edge
          ///
          /// Parent Type: `AnswerStatusEdge`
          public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AnswerStatusEdge }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("node", Node.self),
            ] }

            public var node: Node { __data["node"] }

            /// CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection.Edge.Node
            ///
            /// Parent Type: `AnswerStatus`
            public struct Node: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AnswerStatus }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("questionId", KnowledgeGraphQLEntities.EncodedId.self),
                .field("status", GraphQLEnum<KnowledgeGraphQLEntities.QuestionAnsweredStatus>.self),
              ] }

              public var questionId: KnowledgeGraphQLEntities.EncodedId { __data["questionId"] }
              public var status: GraphQLEnum<KnowledgeGraphQLEntities.QuestionAnsweredStatus> { __data["status"] }
            }
          }
        }
      }
    }
  }
}
