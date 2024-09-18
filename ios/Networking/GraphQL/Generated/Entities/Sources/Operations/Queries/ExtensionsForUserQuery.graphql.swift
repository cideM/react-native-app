// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ExtensionsForUserQuery: GraphQLQuery {
  public static let operationName: String = "ExtensionsForUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ExtensionsForUser($userId: EncodedId!, $first: Int!, $after: String) { userParticleExtensions(userId: $userId, first: $first, after: $after) { __typename edges { __typename node { __typename eid text particleEid updatedAt particle { __typename article { __typename eid } } } } pageInfo { __typename endCursor hasNextPage } } }"#
    ))

  public var userId: EncodedId
  public var first: Int
  public var after: GraphQLNullable<String>

  public init(
    userId: EncodedId,
    first: Int,
    after: GraphQLNullable<String>
  ) {
    self.userId = userId
    self.first = first
    self.after = after
  }

  public var __variables: Variables? { [
    "userId": userId,
    "first": first,
    "after": after
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("userParticleExtensions", UserParticleExtensions?.self, arguments: [
        "userId": .variable("userId"),
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }

    /// Get a specific user's particle extensions
    public var userParticleExtensions: UserParticleExtensions? { __data["userParticleExtensions"] }

    /// UserParticleExtensions
    ///
    /// Parent Type: `ParticleExtensionConnection`
    public struct UserParticleExtensions: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtensionConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var edges: [Edge] { __data["edges"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// UserParticleExtensions.Edge
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

        /// UserParticleExtensions.Edge.Node
        ///
        /// Parent Type: `ParticleExtension`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtension }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("eid", KnowledgeGraphQLEntities.ID.self),
            .field("text", String?.self),
            .field("particleEid", KnowledgeGraphQLEntities.ID.self),
            .field("updatedAt", String.self),
            .field("particle", Particle.self),
          ] }

          public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
          public var text: String? { __data["text"] }
          public var particleEid: KnowledgeGraphQLEntities.ID { __data["particleEid"] }
          public var updatedAt: String { __data["updatedAt"] }
          public var particle: Particle { __data["particle"] }

          /// UserParticleExtensions.Edge.Node.Particle
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

            /// UserParticleExtensions.Edge.Node.Particle.Article
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

      /// UserParticleExtensions.PageInfo
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
    }
  }
}
