// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentUserConfigQuery: GraphQLQuery {
  public static let operationName: String = "CurrentUserConfig"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentUserConfig { currentUserConfig { __typename hasConfirmedHealthCareProfession } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentUserConfig", CurrentUserConfig.self),
    ] }

    /// Fetch the current user's configuration
    public var currentUserConfig: CurrentUserConfig { __data["currentUserConfig"] }

    /// CurrentUserConfig
    ///
    /// Parent Type: `UserConfig`
    public struct CurrentUserConfig: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.UserConfig }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("hasConfirmedHealthCareProfession", Bool.self),
      ] }

      public var hasConfirmedHealthCareProfession: Bool { __data["hasConfirmedHealthCareProfession"] }
    }
  }
}
