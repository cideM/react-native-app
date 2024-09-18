// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateCurrentUserProfileMutation: GraphQLMutation {
  public static let operationName: String = "updateCurrentUserProfile"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation updateCurrentUserProfile($userProfileInput: UserProfileInput!) { updateCurrentUserProfile(userProfile: $userProfileInput) { __typename ... on User { eid } } }"#
    ))

  public var userProfileInput: UserProfileInput

  public init(userProfileInput: UserProfileInput) {
    self.userProfileInput = userProfileInput
  }

  public var __variables: Variables? { ["userProfileInput": userProfileInput] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCurrentUserProfile", UpdateCurrentUserProfile.self, arguments: ["userProfile": .variable("userProfileInput")]),
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

        public typealias RootEntityType = UpdateCurrentUserProfileMutation.Data.UpdateCurrentUserProfile
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("eid", String.self),
        ] }

        public var eid: String { __data["eid"] }
      }
    }
  }
}
