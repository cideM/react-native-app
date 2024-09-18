// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MonographQuery: GraphQLQuery {
  public static let operationName: String = "monograph"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query monograph($monographId: ID!) { ambossSubstance(id: $monographId) { __typename id monograph { __typename id title brandNames generic publishedAt html classification { __typename ahfsCode ahfsTitle atcCode atcTitle } } } }"#
    ))

  public var monographId: ID

  public init(monographId: ID) {
    self.monographId = monographId
  }

  public var __variables: Variables? { ["monographId": monographId] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("ambossSubstance", AmbossSubstance.self, arguments: ["id": .variable("monographId")]),
    ] }

    /// Get Amboss Substance by ID.
    public var ambossSubstance: AmbossSubstance { __data["ambossSubstance"] }

    /// AmbossSubstance
    ///
    /// Parent Type: `AmbossSubstance`
    public struct AmbossSubstance: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AmbossSubstance }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KnowledgeGraphQLEntities.ID.self),
        .field("monograph", Monograph?.self),
      ] }

      public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
      public var monograph: Monograph? { __data["monograph"] }

      /// AmbossSubstance.Monograph
      ///
      /// Parent Type: `PharmaMonograph`
      public struct Monograph: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaMonograph }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", KnowledgeGraphQLEntities.ID.self),
          .field("title", String.self),
          .field("brandNames", [String].self),
          .field("generic", Bool.self),
          .field("publishedAt", KnowledgeGraphQLEntities.DateTime.self),
          .field("html", String.self),
          .field("classification", Classification.self),
        ] }

        public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var brandNames: [String] { __data["brandNames"] }
        public var generic: Bool { __data["generic"] }
        public var publishedAt: KnowledgeGraphQLEntities.DateTime { __data["publishedAt"] }
        public var html: String { __data["html"] }
        public var classification: Classification { __data["classification"] }

        /// AmbossSubstance.Monograph.Classification
        ///
        /// Parent Type: `PharmaMGClassification`
        public struct Classification: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaMGClassification }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("ahfsCode", String.self),
            .field("ahfsTitle", String.self),
            .field("atcCode", String.self),
            .field("atcTitle", String.self),
          ] }

          public var ahfsCode: String { __data["ahfsCode"] }
          public var ahfsTitle: String { __data["ahfsTitle"] }
          public var atcCode: String { __data["atcCode"] }
          public var atcTitle: String { __data["atcTitle"] }
        }
      }
    }
  }
}
