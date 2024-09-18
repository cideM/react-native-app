// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class IssueOneTimeTokenMutation: GraphQLMutation {
  public static let operationName: String = "IssueOneTimeToken"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation IssueOneTimeToken { issueOneTimeToken { __typename token } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("issueOneTimeToken", IssueOneTimeToken?.self),
    ] }

    /// Generates a one time usage token for the current user
    public var issueOneTimeToken: IssueOneTimeToken? { __data["issueOneTimeToken"] }

    /// IssueOneTimeToken
    ///
    /// Parent Type: `OneTimeToken`
    public struct IssueOneTimeToken: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.OneTimeToken }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("token", String.self),
      ] }

      public var token: String { __data["token"] }
    }
  }
}
