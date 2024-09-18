// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateHealthCareProfessionMutation: GraphQLMutation {
  public static let operationName: String = "UpdateHealthCareProfession"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateHealthCareProfession($hasConfirmedHealthCareProfession: Boolean!) { updateCurrentUserConfig( config: { hasConfirmedHealthCareProfession: $hasConfirmedHealthCareProfession } ) { __typename hasConfirmedHealthCareProfession } }"#
    ))

  public var hasConfirmedHealthCareProfession: Bool

  public init(hasConfirmedHealthCareProfession: Bool) {
    self.hasConfirmedHealthCareProfession = hasConfirmedHealthCareProfession
  }

  public var __variables: Variables? { ["hasConfirmedHealthCareProfession": hasConfirmedHealthCareProfession] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCurrentUserConfig", UpdateCurrentUserConfig.self, arguments: ["config": ["hasConfirmedHealthCareProfession": .variable("hasConfirmedHealthCareProfession")]]),
    ] }

    /// Update the current user's configuration
    public var updateCurrentUserConfig: UpdateCurrentUserConfig { __data["updateCurrentUserConfig"] }

    /// UpdateCurrentUserConfig
    ///
    /// Parent Type: `UserConfig`
    public struct UpdateCurrentUserConfig: KnowledgeGraphQLEntities.SelectionSet {
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
