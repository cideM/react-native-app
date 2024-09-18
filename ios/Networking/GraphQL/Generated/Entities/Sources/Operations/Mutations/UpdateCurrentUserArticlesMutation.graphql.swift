// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateCurrentUserArticlesMutation: GraphQLMutation {
  public static let operationName: String = "UpdateCurrentUserArticles"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateCurrentUserArticles($userArticles: [UserArticleInput!]!) { updateCurrentUserArticles(userArticles: $userArticles) { __typename type articleEid active } }"#
    ))

  public var userArticles: [UserArticleInput]

  public init(userArticles: [UserArticleInput]) {
    self.userArticles = userArticles
  }

  public var __variables: Variables? { ["userArticles": userArticles] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCurrentUserArticles", [UpdateCurrentUserArticle]?.self, arguments: ["userArticles": .variable("userArticles")]),
    ] }

    /// Set and unset the status of many articles
    public var updateCurrentUserArticles: [UpdateCurrentUserArticle]? { __data["updateCurrentUserArticles"] }

    /// UpdateCurrentUserArticle
    ///
    /// Parent Type: `ArticleInteraction`
    public struct UpdateCurrentUserArticle: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ArticleInteraction }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("type", GraphQLEnum<KnowledgeGraphQLEntities.ArticleInteractionType>.self),
        .field("articleEid", KnowledgeGraphQLEntities.ID.self),
        .field("active", Bool.self),
      ] }

      public var type: GraphQLEnum<KnowledgeGraphQLEntities.ArticleInteractionType> { __data["type"] }
      public var articleEid: KnowledgeGraphQLEntities.ID { __data["articleEid"] }
      public var active: Bool { __data["active"] }
    }
  }
}
