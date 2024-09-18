// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UploadIosIapReceiptMutation: GraphQLMutation {
  public static let operationName: String = "UploadIosIapReceipt"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UploadIosIapReceipt($uploadFile: Upload!, $appIdentifier: String!, $countryCode: String) { uploadIosIapReceipt( iosReceipt: $uploadFile appIdentifier: $appIdentifier countryCode: $countryCode ) { __typename ... on IosSubscription { startDate renewalDate appleProductId } ... on IosSubscriptionError { code } } }"#
    ))

  public var uploadFile: Upload
  public var appIdentifier: String
  public var countryCode: GraphQLNullable<String>

  public init(
    uploadFile: Upload,
    appIdentifier: String,
    countryCode: GraphQLNullable<String>
  ) {
    self.uploadFile = uploadFile
    self.appIdentifier = appIdentifier
    self.countryCode = countryCode
  }

  public var __variables: Variables? { [
    "uploadFile": uploadFile,
    "appIdentifier": appIdentifier,
    "countryCode": countryCode
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("uploadIosIapReceipt", UploadIosIapReceipt.self, arguments: [
        "iosReceipt": .variable("uploadFile"),
        "appIdentifier": .variable("appIdentifier"),
        "countryCode": .variable("countryCode")
      ]),
    ] }

    /// Mutation used to upload a IOS IAP purchase receipt and create UserAccesses
    public var uploadIosIapReceipt: UploadIosIapReceipt { __data["uploadIosIapReceipt"] }

    /// UploadIosIapReceipt
    ///
    /// Parent Type: `UploadReceiptResult`
    public struct UploadIosIapReceipt: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.UploadReceiptResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsIosSubscription.self),
        .inlineFragment(AsIosSubscriptionError.self),
      ] }

      public var asIosSubscription: AsIosSubscription? { _asInlineFragment() }
      public var asIosSubscriptionError: AsIosSubscriptionError? { _asInlineFragment() }

      /// UploadIosIapReceipt.AsIosSubscription
      ///
      /// Parent Type: `IosSubscription`
      public struct AsIosSubscription: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = UploadIosIapReceiptMutation.Data.UploadIosIapReceipt
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.IosSubscription }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("startDate", KnowledgeGraphQLEntities.DateTime.self),
          .field("renewalDate", KnowledgeGraphQLEntities.DateTime.self),
          .field("appleProductId", String.self),
        ] }

        /// UTC, ISO 8601 (YYYY-MM-DDThh:mm:ss+00:00)
        public var startDate: KnowledgeGraphQLEntities.DateTime { __data["startDate"] }
        /// UTC, ISO 8601 (YYYY-MM-DDThh:mm:ss+00:00)
        public var renewalDate: KnowledgeGraphQLEntities.DateTime { __data["renewalDate"] }
        /// Product id defined in the Apple Store
        public var appleProductId: String { __data["appleProductId"] }
      }

      /// UploadIosIapReceipt.AsIosSubscriptionError
      ///
      /// Parent Type: `IosSubscriptionError`
      public struct AsIosSubscriptionError: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = UploadIosIapReceiptMutation.Data.UploadIosIapReceipt
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.IosSubscriptionError }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("code", GraphQLEnum<KnowledgeGraphQLEntities.IosSubscriptionErrorCode>.self),
        ] }

        public var code: GraphQLEnum<KnowledgeGraphQLEntities.IosSubscriptionErrorCode> { __data["code"] }
      }
    }
  }
}
