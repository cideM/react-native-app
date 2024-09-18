// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SubmitFeedbackMutation: GraphQLMutation {
  public static let operationName: String = "SubmitFeedback"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SubmitFeedback($input: FeedbackInput!) { submitFeedback(feedback: $input) { __typename success } }"#
    ))

  public var input: FeedbackInput

  public init(input: FeedbackInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("submitFeedback", SubmitFeedback.self, arguments: ["feedback": .variable("input")]),
    ] }

    /// Submit user's feedback to a particular piece of content
    public var submitFeedback: SubmitFeedback { __data["submitFeedback"] }

    /// SubmitFeedback
    ///
    /// Parent Type: `FeedbackSubmissionResult`
    public struct SubmitFeedback: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.FeedbackSubmissionResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("success", Bool.self),
      ] }

      public var success: Bool { __data["success"] }
    }
  }
}
