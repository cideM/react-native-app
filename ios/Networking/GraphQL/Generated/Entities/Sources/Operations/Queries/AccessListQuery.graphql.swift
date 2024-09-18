// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AccessListQuery: GraphQLQuery {
  public static let operationName: String = "AccessList"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query AccessList { currentUser { __typename mobileAccessList { __typename ... on MobileAccessError { __typename target errorCode } ... on MobileAccess { __typename target offlineExpiryDate } } } }"#
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
        .field("mobileAccessList", [MobileAccessList]?.self),
      ] }

      /// Get list of mobile accesses
      public var mobileAccessList: [MobileAccessList]? { __data["mobileAccessList"] }

      /// CurrentUser.MobileAccessList
      ///
      /// Parent Type: `MobileAccessUnion`
      public struct MobileAccessList: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.MobileAccessUnion }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsMobileAccessError.self),
          .inlineFragment(AsMobileAccess.self),
        ] }

        public var asMobileAccessError: AsMobileAccessError? { _asInlineFragment() }
        public var asMobileAccess: AsMobileAccess? { _asInlineFragment() }

        /// CurrentUser.MobileAccessList.AsMobileAccessError
        ///
        /// Parent Type: `MobileAccessError`
        public struct AsMobileAccessError: KnowledgeGraphQLEntities.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AccessListQuery.Data.CurrentUser.MobileAccessList
          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.MobileAccessError }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("target", GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessTargetType>.self),
            .field("errorCode", GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessErrorCodeType>?.self),
          ] }

          public var target: GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessTargetType> { __data["target"] }
          public var errorCode: GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessErrorCodeType>? { __data["errorCode"] }
        }

        /// CurrentUser.MobileAccessList.AsMobileAccess
        ///
        /// Parent Type: `MobileAccess`
        public struct AsMobileAccess: KnowledgeGraphQLEntities.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AccessListQuery.Data.CurrentUser.MobileAccessList
          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.MobileAccess }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("target", GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessTargetType>.self),
            .field("offlineExpiryDate", KnowledgeGraphQLEntities.DateTime.self),
          ] }

          public var target: GraphQLEnum<KnowledgeGraphQLEntities.MobileAccessTargetType> { __data["target"] }
          public var offlineExpiryDate: KnowledgeGraphQLEntities.DateTime { __data["offlineExpiryDate"] }
        }
      }
    }
  }
}
