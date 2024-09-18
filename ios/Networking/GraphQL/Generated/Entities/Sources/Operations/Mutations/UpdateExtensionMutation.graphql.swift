// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateExtensionMutation: GraphQLMutation {
  public static let operationName: String = "UpdateExtension"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateExtension($particleEid: ID!, $text: String!) { updateCurrentUserParticleExtension(particleEid: $particleEid, text: $text) { __typename text eid ownerName particleEid updatedAt } }"#
    ))

  public var particleEid: ID
  public var text: String

  public init(
    particleEid: ID,
    text: String
  ) {
    self.particleEid = particleEid
    self.text = text
  }

  public var __variables: Variables? { [
    "particleEid": particleEid,
    "text": text
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateCurrentUserParticleExtension", UpdateCurrentUserParticleExtension.self, arguments: [
        "particleEid": .variable("particleEid"),
        "text": .variable("text")
      ]),
    ] }

    /// Adds or updates a user extension for a specific particle
    public var updateCurrentUserParticleExtension: UpdateCurrentUserParticleExtension { __data["updateCurrentUserParticleExtension"] }

    /// UpdateCurrentUserParticleExtension
    ///
    /// Parent Type: `ParticleExtension`
    public struct UpdateCurrentUserParticleExtension: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ParticleExtension }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("text", String?.self),
        .field("eid", KnowledgeGraphQLEntities.ID.self),
        .field("ownerName", String.self),
        .field("particleEid", KnowledgeGraphQLEntities.ID.self),
        .field("updatedAt", String.self),
      ] }

      public var text: String? { __data["text"] }
      public var eid: KnowledgeGraphQLEntities.ID { __data["eid"] }
      public var ownerName: String { __data["ownerName"] }
      public var particleEid: KnowledgeGraphQLEntities.ID { __data["particleEid"] }
      public var updatedAt: String { __data["updatedAt"] }
    }
  }
}
