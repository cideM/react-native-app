// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PhraseGroupQuery: GraphQLQuery {
  public static let operationName: String = "phraseGroup"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query phraseGroup($eid: String!) { phraseGroup(eid: $eid) { __typename eid title synonyms abstract translation destinations { __typename label articleEid particleEid anchor } } }"#
    ))

  public var eid: String

  public init(eid: String) {
    self.eid = eid
  }

  public var __variables: Variables? { ["eid": eid] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("phraseGroup", PhraseGroup?.self, arguments: ["eid": .variable("eid")]),
    ] }

    /// Fetch phraseGroup by eid
    public var phraseGroup: PhraseGroup? { __data["phraseGroup"] }

    /// PhraseGroup
    ///
    /// Parent Type: `PhraseGroup`
    public struct PhraseGroup: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PhraseGroup }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("eid", String.self),
        .field("title", String?.self),
        .field("synonyms", [String].self),
        .field("abstract", String?.self),
        .field("translation", String?.self),
        .field("destinations", [Destination].self),
      ] }

      public var eid: String { __data["eid"] }
      /// the top-ranking *synonym* alias *Primary Lexeme*
      public var title: String? { __data["title"] }
      /// all other *lexemes* (i.e. visible Phrases) but the primary one i.e. title
      public var synonyms: [String] { __data["synonyms"] }
      /// alias *description* (or *explanation* in DB)
      public var abstract: String? { __data["abstract"] }
      /// alias *etymology* (translation in DB)
      public var translation: String? { __data["translation"] }
      public var destinations: [Destination] { __data["destinations"] }

      /// PhraseGroup.Destination
      ///
      /// Parent Type: `SememeDestination`
      public struct Destination: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SememeDestination }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("label", String?.self),
          .field("articleEid", KnowledgeGraphQLEntities.ID.self),
          .field("particleEid", KnowledgeGraphQLEntities.ID?.self),
          .field("anchor", String.self),
        ] }

        /// link label
        public var label: String? { __data["label"] }
        /// Destination's article id
        public var articleEid: KnowledgeGraphQLEntities.ID { __data["articleEid"] }
        /// Destinations's particle id
        public var particleEid: KnowledgeGraphQLEntities.ID? { __data["particleEid"] }
        /// Destination's anchor id
        public var anchor: String { __data["anchor"] }
      }
    }
  }
}
