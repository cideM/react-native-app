// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MediaAssetsQuery: GraphQLQuery {
  public static let operationName: String = "MediaAssets"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MediaAssets($featureEids: [String!]!) { mediaAssets(eids: $featureEids) { __typename eid externalAddition { __typename ... on ExternalAddition { __typename type url isFreebie } ... on BlockedExternalAddition { __typename type } } } }"#
    ))

  public var featureEids: [String]

  public init(featureEids: [String]) {
    self.featureEids = featureEids
  }

  public var __variables: Variables? { ["featureEids": featureEids] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("mediaAssets", [MediaAsset].self, arguments: ["eids": .variable("featureEids")]),
    ] }

    /// Fetch media by list of ids
    public var mediaAssets: [MediaAsset] { __data["mediaAssets"] }

    /// MediaAsset
    ///
    /// Parent Type: `MediaAsset`
    public struct MediaAsset: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.MediaAsset }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("eid", String.self),
        .field("externalAddition", ExternalAddition?.self),
      ] }

      public var eid: String { __data["eid"] }
      public var externalAddition: ExternalAddition? { __data["externalAddition"] }

      /// MediaAsset.ExternalAddition
      ///
      /// Parent Type: `ExternalAdditionResult`
      public struct ExternalAddition: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.ExternalAdditionResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsExternalAddition.self),
          .inlineFragment(AsBlockedExternalAddition.self),
        ] }

        public var asExternalAddition: AsExternalAddition? { _asInlineFragment() }
        public var asBlockedExternalAddition: AsBlockedExternalAddition? { _asInlineFragment() }

        /// MediaAsset.ExternalAddition.AsExternalAddition
        ///
        /// Parent Type: `ExternalAddition`
        public struct AsExternalAddition: KnowledgeGraphQLEntities.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = MediaAssetsQuery.Data.MediaAsset.ExternalAddition
          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ExternalAddition }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("type", GraphQLEnum<KnowledgeGraphQLEntities.AdditionType>.self),
            .field("url", String.self),
            .field("isFreebie", Bool.self),
          ] }

          public var type: GraphQLEnum<KnowledgeGraphQLEntities.AdditionType> { __data["type"] }
          public var url: String { __data["url"] }
          public var isFreebie: Bool { __data["isFreebie"] }
        }

        /// MediaAsset.ExternalAddition.AsBlockedExternalAddition
        ///
        /// Parent Type: `BlockedExternalAddition`
        public struct AsBlockedExternalAddition: KnowledgeGraphQLEntities.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = MediaAssetsQuery.Data.MediaAsset.ExternalAddition
          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.BlockedExternalAddition }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("type", GraphQLEnum<KnowledgeGraphQLEntities.AdditionType>.self),
          ] }

          public var type: GraphQLEnum<KnowledgeGraphQLEntities.AdditionType> { __data["type"] }
        }
      }
    }
  }
}
