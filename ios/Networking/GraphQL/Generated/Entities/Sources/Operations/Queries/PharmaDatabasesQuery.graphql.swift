// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PharmaDatabasesQuery: GraphQLQuery {
  public static let operationName: String = "pharmaDatabases"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query pharmaDatabases($pharmaDBMajorVersion: Int!) { pharmaDatabases(major: $pharmaDBMajorVersion) { __typename major minor patch size zippedSize url dateCreated } }"#
    ))

  public var pharmaDBMajorVersion: Int

  public init(pharmaDBMajorVersion: Int) {
    self.pharmaDBMajorVersion = pharmaDBMajorVersion
  }

  public var __variables: Variables? { ["pharmaDBMajorVersion": pharmaDBMajorVersion] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("pharmaDatabases", [PharmaDatabase].self, arguments: ["major": .variable("pharmaDBMajorVersion")]),
    ] }

    /// Get a list of Pharma offline db versions by a given major version number.
    public var pharmaDatabases: [PharmaDatabase] { __data["pharmaDatabases"] }

    /// PharmaDatabase
    ///
    /// Parent Type: `PharmaDatabase`
    public struct PharmaDatabase: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaDatabase }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("major", Int.self),
        .field("minor", Int.self),
        .field("patch", Int.self),
        .field("size", Int.self),
        .field("zippedSize", Int.self),
        .field("url", String.self),
        .field("dateCreated", KnowledgeGraphQLEntities.DateTime.self),
      ] }

      public var major: Int { __data["major"] }
      public var minor: Int { __data["minor"] }
      public var patch: Int { __data["patch"] }
      public var size: Int { __data["size"] }
      public var zippedSize: Int { __data["zippedSize"] }
      public var url: String { __data["url"] }
      public var dateCreated: KnowledgeGraphQLEntities.DateTime { __data["dateCreated"] }
    }
  }
}
