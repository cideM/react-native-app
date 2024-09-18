// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AvailableStudyObjectivesQuery: GraphQLQuery {
  public static let operationName: String = "AvailableStudyObjectives"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query AvailableStudyObjectives { currentUser { __typename availableStudyObjectives { __typename eid label superset } studyObjective { __typename eid label superset } } }"#
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
        .field("availableStudyObjectives", [AvailableStudyObjective]?.self),
        .field("studyObjective", StudyObjective?.self),
      ] }

      /// Get list of available and selectable study objectives for the current user
      public var availableStudyObjectives: [AvailableStudyObjective]? { __data["availableStudyObjectives"] }
      /// Only available in US currently
      public var studyObjective: StudyObjective? { __data["studyObjective"] }

      /// CurrentUser.AvailableStudyObjective
      ///
      /// Parent Type: `StudyObjective`
      public struct AvailableStudyObjective: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.StudyObjective }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("eid", KnowledgeGraphQLEntities.ID.self),
          .field("label", String.self),
          .field("superset", String?.self),
        ] }

        public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
        public var label: String { __data["label"] }
        public var superset: String? { __data["superset"] }
      }

      /// CurrentUser.StudyObjective
      ///
      /// Parent Type: `StudyObjective`
      public struct StudyObjective: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.StudyObjective }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("eid", KnowledgeGraphQLEntities.ID.self),
          .field("label", String.self),
          .field("superset", String?.self),
        ] }

        public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
        public var label: String { __data["label"] }
        public var superset: String? { __data["superset"] }
      }
    }
  }
}
