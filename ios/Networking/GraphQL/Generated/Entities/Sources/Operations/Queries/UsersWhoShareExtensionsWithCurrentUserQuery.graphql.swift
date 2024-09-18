// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UsersWhoShareExtensionsWithCurrentUserQuery: GraphQLQuery {
  public static let operationName: String = "UsersWhoShareExtensionsWithCurrentUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query UsersWhoShareExtensionsWithCurrentUser($first: Int!, $after: String) { currentUser { __typename latestParticleExtensionUpdatedAt usersWhoShareNotesWithMe(first: $first, after: $after) { __typename pageInfo { __typename endCursor hasNextPage } edges { __typename node { __typename eid email firstName lastName latestParticleExtensionUpdatedAt } } } } }"#
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
        .field("latestParticleExtensionUpdatedAt", KnowledgeGraphQLEntities.DateTime?.self),
        .field("usersWhoShareNotesWithMe", UsersWhoShareNotesWithMe?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// Moment when the latest notes was created or updated
      public var latestParticleExtensionUpdatedAt: KnowledgeGraphQLEntities.DateTime? { __data["latestParticleExtensionUpdatedAt"] }
      /// User who have shared notes with me
      public var usersWhoShareNotesWithMe: UsersWhoShareNotesWithMe? { __data["usersWhoShareNotesWithMe"] }

      /// CurrentUser.UsersWhoShareNotesWithMe
      ///
      /// Parent Type: `UserConnection`
      public struct UsersWhoShareNotesWithMe: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.UserConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// CurrentUser.UsersWhoShareNotesWithMe.PageInfo
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

        /// CurrentUser.UsersWhoShareNotesWithMe.Edge
        ///
        /// Parent Type: `UserEdge`
        public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.UserEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// CurrentUser.UsersWhoShareNotesWithMe.Edge.Node
          ///
          /// Parent Type: `User`
          public struct Node: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("eid", String.self),
              .field("email", String?.self),
              .field("firstName", String?.self),
              .field("lastName", String?.self),
              .field("latestParticleExtensionUpdatedAt", KnowledgeGraphQLEntities.DateTime?.self),
            ] }

            public var eid: String { __data["eid"] }
            public var email: String? { __data["email"] }
            public var firstName: String? { __data["firstName"] }
            public var lastName: String? { __data["lastName"] }
            /// Moment when the latest notes was created or updated
            public var latestParticleExtensionUpdatedAt: KnowledgeGraphQLEntities.DateTime? { __data["latestParticleExtensionUpdatedAt"] }
          }
        }
      }
    }
  }
}
