// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentUserSessionsQuery: GraphQLQuery {
  public static let operationName: String = "CurrentUserSessions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentUserSessions($first: Int!) { currentUserQuestionSessions(first: $first) { __typename edges { __typename node { __typename eid title createdAt questionCount sessionPerformance { __typename totalQuestions completedQuestions } } } } }"#
    ))

  public var first: Int

  public init(first: Int) {
    self.first = first
  }

  public var __variables: Variables? { ["first": first] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentUserQuestionSessions", CurrentUserQuestionSessions.self, arguments: ["first": .variable("first")]),
    ] }

    /// paginated list of the current user's QuestionSessions
    public var currentUserQuestionSessions: CurrentUserQuestionSessions { __data["currentUserQuestionSessions"] }

    /// CurrentUserQuestionSessions
    ///
    /// Parent Type: `QuestionSessionConnection`
    public struct CurrentUserQuestionSessions: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.QuestionSessionConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("edges", [Edge].self),
      ] }

      public var edges: [Edge] { __data["edges"] }

      /// CurrentUserQuestionSessions.Edge
      ///
      /// Parent Type: `QuestionSessionEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.QuestionSessionEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// CurrentUserQuestionSessions.Edge.Node
        ///
        /// Parent Type: `QuestionSession`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.QuestionSession }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("eid", KnowledgeGraphQLEntities.ID.self),
            .field("title", String.self),
            .field("createdAt", String.self),
            .field("questionCount", Int.self),
            .field("sessionPerformance", SessionPerformance.self),
          ] }

          public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
          public var title: String { __data["title"] }
          /// UTC, ISO 8601 (YYYY-MM-DDThh:mm:ss+00:00)
          public var createdAt: String { __data["createdAt"] }
          /// 	total number of questions referenced by this questionCollection/session
          /// 	CAVE: not covering unpublished questions, or newly required preceding questions to a collection's one
          public var questionCount: Int { __data["questionCount"] }
          /// session performance parameters
          public var sessionPerformance: SessionPerformance { __data["sessionPerformance"] }

          /// CurrentUserQuestionSessions.Edge.Node.SessionPerformance
          ///
          /// Parent Type: `QuestionSetPerformance`
          public struct SessionPerformance: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.QuestionSetPerformance }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("totalQuestions", Int.self),
              .field("completedQuestions", Int.self),
            ] }

            /// Total count of question in the set
            public var totalQuestions: Int { __data["totalQuestions"] }
            /// Total amount of questions that are answered
            public var completedQuestions: Int { __data["completedQuestions"] }
          }
        }
      }
    }
  }
}
