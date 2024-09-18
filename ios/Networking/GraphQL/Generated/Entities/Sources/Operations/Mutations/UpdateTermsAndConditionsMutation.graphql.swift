// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateTermsAndConditionsMutation: GraphQLMutation {
  public static let operationName: String = "updateTermsAndConditions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation updateTermsAndConditions($userProfile: UserProfileInput!) { updateCurrentUserProfile(userProfile: $userProfile) { __typename ... on User { termsAndConditionsId shouldUpdateTnC } } }"#
    ))

  public var userProfile: UserProfileInput

  public init(userProfile: UserProfileInput) {
    self.userProfile = userProfile
  }

  public var __variables: Variables? { ["userProfile": userProfile] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCurrentUserProfile", UpdateCurrentUserProfile.self, arguments: ["userProfile": .variable("userProfile")]),
    ] }

    /// Update user profile
    public var updateCurrentUserProfile: UpdateCurrentUserProfile { __data["updateCurrentUserProfile"] }

    /// UpdateCurrentUserProfile
    ///
    /// Parent Type: `UserProfileResult`
    public struct UpdateCurrentUserProfile: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.UserProfileResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsUser.self),
      ] }

      public var asUser: AsUser? { _asInlineFragment() }

      /// UpdateCurrentUserProfile.AsUser
      ///
      /// Parent Type: `User`
      public struct AsUser: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = UpdateTermsAndConditionsMutation.Data.UpdateCurrentUserProfile
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("termsAndConditionsId", KnowledgeGraphQLEntities.EncodedId?.self),
          .field("shouldUpdateTnC", Bool.self),
        ] }

        /// Terms and Conditions version the user has accepted
        public var termsAndConditionsId: KnowledgeGraphQLEntities.EncodedId? { __data["termsAndConditionsId"] }
        /// Should the user see and update the latest TnC modal
        public var shouldUpdateTnC: Bool { __data["shouldUpdateTnC"] }
      }
    }
  }
}
