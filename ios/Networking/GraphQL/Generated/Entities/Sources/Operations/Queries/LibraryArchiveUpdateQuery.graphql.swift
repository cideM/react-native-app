// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LibraryArchiveUpdateQuery: GraphQLQuery {
  public static let operationName: String = "LibraryArchiveUpdate"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query LibraryArchiveUpdate($currentVersion: Int!) { latestFullLibraryArchive { __typename version url size createdAt } fullLibraryArchive(version: $currentVersion) { __typename updateMode } }"#
    ))

  public var currentVersion: Int

  public init(currentVersion: Int) {
    self.currentVersion = currentVersion
  }

  public var __variables: Variables? { ["currentVersion": currentVersion] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("latestFullLibraryArchive", LatestFullLibraryArchive.self),
      .field("fullLibraryArchive", FullLibraryArchive?.self, arguments: ["version": .variable("currentVersion")]),
    ] }

    /// Get the latest version of the libraryArchive
    public var latestFullLibraryArchive: LatestFullLibraryArchive { __data["latestFullLibraryArchive"] }
    /// Get a specific version of the library archive by a given version number
    public var fullLibraryArchive: FullLibraryArchive? { __data["fullLibraryArchive"] }

    /// LatestFullLibraryArchive
    ///
    /// Parent Type: `LibraryArchive`
    public struct LatestFullLibraryArchive: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.LibraryArchive }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("version", Int.self),
        .field("url", String.self),
        .field("size", Int.self),
        .field("createdAt", String.self),
      ] }

      public var version: Int { __data["version"] }
      public var url: String { __data["url"] }
      public var size: Int { __data["size"] }
      public var createdAt: String { __data["createdAt"] }
    }

    /// FullLibraryArchive
    ///
    /// Parent Type: `LibraryArchive`
    public struct FullLibraryArchive: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.LibraryArchive }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("updateMode", GraphQLEnum<KnowledgeGraphQLEntities.ArchiveLibraryUpdateMode>?.self),
      ] }

      public var updateMode: GraphQLEnum<KnowledgeGraphQLEntities.ArchiveLibraryUpdateMode>? { __data["updateMode"] }
    }
  }
}
