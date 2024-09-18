// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PharmaDosageQuery: GraphQLQuery {
  public static let operationName: String = "pharmaDosage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query pharmaDosage($id: ID!) { dosage(id: $id) { __typename id ambossSubstanceLink { __typename ambossSubstance { __typename id name } drug { __typename id } monograph { __typename id } } content { __typename html } } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dosage", Dosage.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get Pharma Dosage by ID.
    public var dosage: Dosage { __data["dosage"] }

    /// Dosage
    ///
    /// Parent Type: `Dosage`
    public struct Dosage: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Dosage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KnowledgeGraphQLEntities.ID.self),
        .field("ambossSubstanceLink", AmbossSubstanceLink?.self),
        .field("content", Content.self),
      ] }

      public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
      public var ambossSubstanceLink: AmbossSubstanceLink? { __data["ambossSubstanceLink"] }
      public var content: Content { __data["content"] }

      /// Dosage.AmbossSubstanceLink
      ///
      /// Parent Type: `AmbossSubstanceLink`
      public struct AmbossSubstanceLink: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AmbossSubstanceLink }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("ambossSubstance", AmbossSubstance.self),
          .field("drug", Drug.self),
          .field("monograph", Monograph?.self),
        ] }

        public var ambossSubstance: AmbossSubstance { __data["ambossSubstance"] }
        public var drug: Drug { __data["drug"] }
        public var monograph: Monograph? { __data["monograph"] }

        /// Dosage.AmbossSubstanceLink.AmbossSubstance
        ///
        /// Parent Type: `AmbossSubstance`
        public struct AmbossSubstance: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AmbossSubstance }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", KnowledgeGraphQLEntities.ID.self),
            .field("name", String.self),
          ] }

          public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
          public var name: String { __data["name"] }
        }

        /// Dosage.AmbossSubstanceLink.Drug
        ///
        /// Parent Type: `PharmaDrug`
        public struct Drug: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaDrug }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", KnowledgeGraphQLEntities.ID.self),
          ] }

          public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
        }

        /// Dosage.AmbossSubstanceLink.Monograph
        ///
        /// Parent Type: `PharmaMonograph`
        public struct Monograph: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaMonograph }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", KnowledgeGraphQLEntities.ID.self),
          ] }

          public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
        }
      }

      /// Dosage.Content
      ///
      /// Parent Type: `DosageContent`
      public struct Content: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.DosageContent }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("html", String.self),
        ] }

        public var html: String { __data["html"] }
      }
    }
  }
}
