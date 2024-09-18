// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentUserExtensionsQuery: GraphQLQuery {
  public static let operationName: String = "CurrentUserExtensions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentUserExtensions($first: Int!, $after: String) { currentUser { __typename particleExtensions(first: $first, after: $after) { __typename pageInfo { __typename endCursor hasNextPage } edges { __typename node { __typename text eid particleEid updatedAt particle { __typename article { __typename eid } } } } } } }"#
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
        .field("particleExtensions", ParticleExtensions?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// User notes done in different particles
      public var particleExtensions: ParticleExtensions? { __data["particleExtensions"] }

      /// CurrentUser.ParticleExtensions
      ///
      /// Parent Type: `ParticleExtensionConnection`
      public struct ParticleExtensions: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtensionConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge].self),
        ] }

        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var edges: [Edge] { __data["edges"] }

        /// CurrentUser.ParticleExtensions.PageInfo
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

        /// CurrentUser.ParticleExtensions.Edge
        ///
        /// Parent Type: `ParticleExtensionEdge`
        public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtensionEdge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }

          public var node: Node { __data["node"] }

          /// CurrentUser.ParticleExtensions.Edge.Node
          ///
          /// Parent Type: `ParticleExtension`
          public struct Node: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtension }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("text", String?.self),
              .field("eid", KnowledgeGraphQLEntities.ID.self),
              .field("particleEid", KnowledgeGraphQLEntities.ID.self),
              .field("updatedAt", String.self),
              .field("particle", Particle.self),
            ] }

            public var text: String? { __data["text"] }
            public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
            public var particleEid: KnowledgeGraphQLEntities.ID { __data["particleEid"] }
            public var updatedAt: String { __data["updatedAt"] }
            public var particle: Particle { __data["particle"] }

            /// CurrentUser.ParticleExtensions.Edge.Node.Particle
            ///
            /// Parent Type: `Particle`
            public struct Particle: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Particle }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("article", Article.self),
              ] }

              /// Article this particle belongs
              public var article: Article { __data["article"] }

              /// CurrentUser.ParticleExtensions.Edge.Node.Particle.Article
              ///
              /// Parent Type: `Article`
              public struct Article: KnowledgeGraphQLEntities.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Article }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("eid", String.self),
                ] }

                public var eid: String { __data["eid"] }
              }
            }
          }
        }
      }
    }
  }
}
