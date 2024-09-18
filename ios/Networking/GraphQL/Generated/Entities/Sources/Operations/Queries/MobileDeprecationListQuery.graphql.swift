// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MobileDeprecationListQuery: GraphQLQuery {
  public static let operationName: String = "MobileDeprecationList"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MobileDeprecationList { mobileDeprecationList { __typename minVersion maxVersion deprecationType mobilePlatform mobileIdentifier deprecationExplanationUrl } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("mobileDeprecationList", [MobileDeprecationList?]?.self),
    ] }

    /// List of available mobile version deprecations
    public var mobileDeprecationList: [MobileDeprecationList?]? { __data["mobileDeprecationList"] }

    /// MobileDeprecationList
    ///
    /// Parent Type: `MobileDeprecation`
    public struct MobileDeprecationList: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.MobileDeprecation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("minVersion", String.self),
        .field("maxVersion", String.self),
        .field("deprecationType", GraphQLEnum<KnowledgeGraphQLEntities.MobileDeprecationType>.self),
        .field("mobilePlatform", GraphQLEnum<KnowledgeGraphQLEntities.MobilePlatform>.self),
        .field("mobileIdentifier", String.self),
        .field("deprecationExplanationUrl", String?.self),
      ] }

      public var minVersion: String { __data["minVersion"] }
      public var maxVersion: String { __data["maxVersion"] }
      public var deprecationType: GraphQLEnum<KnowledgeGraphQLEntities.MobileDeprecationType> { __data["deprecationType"] }
      public var mobilePlatform: GraphQLEnum<KnowledgeGraphQLEntities.MobilePlatform> { __data["mobilePlatform"] }
      /// Unique identifier for the respectve mobile app in Apple store or Google Play
      public var mobileIdentifier: String { __data["mobileIdentifier"] }
      public var deprecationExplanationUrl: String? { __data["deprecationExplanationUrl"] }
    }
  }
}
