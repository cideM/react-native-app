// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentAuthorizationQuery: GraphQLQuery {
  public static let operationName: String = "CurrentAuthorization"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentAuthorization { currentAuthorization { __typename isAuthorized token { __typename issued token deviceId } user { __typename eid firstName lastName } } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentAuthorization", CurrentAuthorization.self),
    ] }

    /// Current authorization can be called for anonymous user without generating an error
    public var currentAuthorization: CurrentAuthorization { __data["currentAuthorization"] }

    /// CurrentAuthorization
    ///
    /// Parent Type: `Authorization`
    public struct CurrentAuthorization: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Authorization }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("isAuthorized", Bool.self),
        .field("token", Token?.self),
        .field("user", User?.self),
      ] }

      /// false if user is not authorized
      public var isAuthorized: Bool { __data["isAuthorized"] }
      /// null if user is not authorized
      public var token: Token? { __data["token"] }
      /// null if user is not authorized
      public var user: User? { __data["user"] }

      /// CurrentAuthorization.Token
      ///
      /// Parent Type: `AuthToken`
      public struct Token: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AuthToken }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("issued", String.self),
          .field("token", String.self),
          .field("deviceId", String.self),
        ] }

        /// Date issued in database format
        public var issued: String { __data["issued"] }
        /// Token string. Add it to Authorization http header
        public var token: String { __data["token"] }
        /// Device id for the token
        public var deviceId: String { __data["deviceId"] }
      }

      /// CurrentAuthorization.User
      ///
      /// Parent Type: `User`
      public struct User: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("eid", String.self),
          .field("firstName", String?.self),
          .field("lastName", String?.self),
        ] }

        public var eid: String { __data["eid"] }
        public var firstName: String? { __data["firstName"] }
        public var lastName: String? { __data["lastName"] }
      }
    }
  }
}
