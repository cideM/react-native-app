// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ApplyProductKeyMutation: GraphQLMutation {
  public static let operationName: String = "ApplyProductKey"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation ApplyProductKey($productKey: String!) { applyProductKey(productKey: $productKey) { __typename ... on ApplyProductKeyResult { __typename productKey } ... on ProductKeyError { __typename errorCode message } } }"#
    ))

  public var productKey: String

  public init(productKey: String) {
    self.productKey = productKey
  }

  public var __variables: Variables? { ["productKey": productKey] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("applyProductKey", ApplyProductKey.self, arguments: ["productKey": .variable("productKey")]),
    ] }

    /// Verifies and apply a product key for the current user
    public var applyProductKey: ApplyProductKey { __data["applyProductKey"] }

    /// ApplyProductKey
    ///
    /// Parent Type: `ApplyProductKeyResultUnion`
    public struct ApplyProductKey: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.ApplyProductKeyResultUnion }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsApplyProductKeyResult.self),
        .inlineFragment(AsProductKeyError.self),
      ] }

      public var asApplyProductKeyResult: AsApplyProductKeyResult? { _asInlineFragment() }
      public var asProductKeyError: AsProductKeyError? { _asInlineFragment() }

      /// ApplyProductKey.AsApplyProductKeyResult
      ///
      /// Parent Type: `ApplyProductKeyResult`
      public struct AsApplyProductKeyResult: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ApplyProductKeyMutation.Data.ApplyProductKey
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ApplyProductKeyResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("productKey", String.self),
        ] }

        /// Product key that was applied
        public var productKey: String { __data["productKey"] }
      }

      /// ApplyProductKey.AsProductKeyError
      ///
      /// Parent Type: `ProductKeyError`
      public struct AsProductKeyError: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ApplyProductKeyMutation.Data.ApplyProductKey
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.ProductKeyError }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("errorCode", GraphQLEnum<KnowledgeGraphQLEntities.ProductKeyErrorCode>.self),
          .field("message", String.self),
        ] }

        public var errorCode: GraphQLEnum<KnowledgeGraphQLEntities.ProductKeyErrorCode> { __data["errorCode"] }
        public var message: String { __data["message"] }
      }
    }
  }
}
