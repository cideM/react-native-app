// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MobileAccessesQuery: GraphQLQuery {
  public static let operationName: String = "MobileAccesses"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MobileAccesses { currentUser { __typename trialInfo { __typename hasTrialAccess } } }"#
    ))

  public init() {}

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
        .field("trialInfo", TrialInfo?.self),
      ] }

      /// Returns the trial status for the current user
      public var trialInfo: TrialInfo? { __data["trialInfo"] }

      /// CurrentUser.TrialInfo
      ///
      /// Parent Type: `TrialInfo`
      public struct TrialInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.TrialInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasTrialAccess", Bool.self),
        ] }

        public var hasTrialAccess: Bool { __data["hasTrialAccess"] }
      }
    }
  }
}
