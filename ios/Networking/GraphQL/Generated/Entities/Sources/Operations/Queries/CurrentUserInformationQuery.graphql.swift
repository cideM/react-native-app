// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentUserInformationQuery: GraphQLQuery {
  public static let operationName: String = "CurrentUserInformation"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentUserInformation { currentUser { __typename shouldUpdateTnC features stage studyObjective { __typename eid label superset } } }"#
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
        .field("shouldUpdateTnC", Bool.self),
        .field("features", [String].self),
        .field("stage", GraphQLEnum<KnowledgeGraphQLEntities.Stage>.self),
        .field("studyObjective", StudyObjective?.self),
      ] }

      /// Should the user see and update the latest TnC modal
      public var shouldUpdateTnC: Bool { __data["shouldUpdateTnC"] }
      /// returns a list of »feature-flags« (i.e. strings) granted to the current user. This will fail if requested for another than the authorized user
      public var features: [String] { __data["features"] }
      public var stage: GraphQLEnum<KnowledgeGraphQLEntities.Stage> { __data["stage"] }
      /// Only available in US currently
      public var studyObjective: StudyObjective? { __data["studyObjective"] }

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
