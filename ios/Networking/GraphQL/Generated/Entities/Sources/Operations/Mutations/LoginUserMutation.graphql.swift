// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LoginUserMutation: GraphQLMutation {
  public static let operationName: String = "LoginUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation LoginUser($username: String!, $password: String!, $deviceid: String!) { login(login: $username, password: $password, deviceId: $deviceid) { __typename token user { __typename eid firstName lastName email } } }"#
    ))

  public var username: String
  public var password: String
  public var deviceid: String

  public init(
    username: String,
    password: String,
    deviceid: String
  ) {
    self.username = username
    self.password = password
    self.deviceid = deviceid
  }

  public var __variables: Variables? { [
    "username": username,
    "password": password,
    "deviceid": deviceid
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("login", Login?.self, arguments: [
        "login": .variable("username"),
        "password": .variable("password"),
        "deviceId": .variable("deviceid")
      ]),
    ] }

    /// 	Validates user/password and returns existing or new token  for deviceId
    /// 	Strict mode enforces the login method that the user is set to (e.g. next API, Keycloak)
    public var login: Login? { __data["login"] }

    /// Login
    ///
    /// Parent Type: `AuthToken`
    public struct Login: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AuthToken }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("token", String.self),
        .field("user", User.self),
      ] }

      /// Token string. Add it to Authorization http header
      public var token: String { __data["token"] }
      /// User linked to the token
      public var user: User { __data["user"] }

      /// Login.User
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
          .field("email", String?.self),
        ] }

        public var eid: String { __data["eid"] }
        public var firstName: String? { __data["firstName"] }
        public var lastName: String? { __data["lastName"] }
        public var email: String? { __data["email"] }
      }
    }
  }
}
