// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RegistrationStudyObjectivesQuery: GraphQLQuery {
  public static let operationName: String = "registrationStudyObjectives"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query registrationStudyObjectives { usmle: studyObjectives(topic: usmle) { __typename eid label } comlex: studyObjectives(topic: comlex) { __typename eid label } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("studyObjectives", alias: "usmle", [Usmle]?.self, arguments: ["topic": "usmle"]),
      .field("studyObjectives", alias: "comlex", [Comlex]?.self, arguments: ["topic": "comlex"]),
    ] }

    /// List of study objectives by a given topic. Only available in US.
    public var usmle: [Usmle]? { __data["usmle"] }
    /// List of study objectives by a given topic. Only available in US.
    public var comlex: [Comlex]? { __data["comlex"] }

    /// Usmle
    ///
    /// Parent Type: `StudyObjective`
    public struct Usmle: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.StudyObjective }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("eid", KnowledgeGraphQLEntities.ID.self),
        .field("label", String.self),
      ] }

      public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
      public var label: String { __data["label"] }
    }

    /// Comlex
    ///
    /// Parent Type: `StudyObjective`
    public struct Comlex: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.StudyObjective }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("eid", KnowledgeGraphQLEntities.ID.self),
        .field("label", String.self),
      ] }

      public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
      public var label: String { __data["label"] }
    }
  }
}
