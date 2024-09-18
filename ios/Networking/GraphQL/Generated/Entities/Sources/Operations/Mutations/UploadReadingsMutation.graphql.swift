// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UploadReadingsMutation: GraphQLMutation {
  public static let operationName: String = "uploadReadings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation uploadReadings($articleReadingCollection: ArticleReadingCollectionInput!) { addLearningCardReadings(articleReadingsCollection: $articleReadingCollection) }"#
    ))

  public var articleReadingCollection: ArticleReadingCollectionInput

  public init(articleReadingCollection: ArticleReadingCollectionInput) {
    self.articleReadingCollection = articleReadingCollection
  }

  public var __variables: Variables? { ["articleReadingCollection": articleReadingCollection] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addLearningCardReadings", Bool?.self, arguments: ["articleReadingsCollection": .variable("articleReadingCollection")]),
    ] }

    /// Adds a collection of articleReadings for the current user.
    public var addLearningCardReadings: Bool? { __data["addLearningCardReadings"] }
  }
}
