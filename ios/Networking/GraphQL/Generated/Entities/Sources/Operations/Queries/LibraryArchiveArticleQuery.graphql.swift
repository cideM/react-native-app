// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LibraryArchiveArticleQuery: GraphQLQuery {
  public static let operationName: String = "LibraryArchiveArticle"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query LibraryArchiveArticle($version: Int!, $eid: ID!) { libraryArchiveArticle(version: $version, eid: $eid) { __typename eid url htmlContent } }"#
    ))

  public var version: Int
  public var eid: ID

  public init(
    version: Int,
    eid: ID
  ) {
    self.version = version
    self.eid = eid
  }

  public var __variables: Variables? { [
    "version": version,
    "eid": eid
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("libraryArchiveArticle", LibraryArchiveArticle?.self, arguments: [
        "version": .variable("version"),
        "eid": .variable("eid")
      ]),
    ] }

    /// Get an Article inside a specific mobile archive
    public var libraryArchiveArticle: LibraryArchiveArticle? { __data["libraryArchiveArticle"] }

    /// LibraryArchiveArticle
    ///
    /// Parent Type: `LibraryArchiveArticle`
    public struct LibraryArchiveArticle: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.LibraryArchiveArticle }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("eid", KnowledgeGraphQLEntities.ID.self),
        .field("url", String.self),
        .field("htmlContent", String.self),
      ] }

      public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
      public var url: String { __data["url"] }
      public var htmlContent: String { __data["htmlContent"] }
    }
  }
}
