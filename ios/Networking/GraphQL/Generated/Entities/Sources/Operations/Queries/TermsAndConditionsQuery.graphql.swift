// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TermsAndConditionsQuery: GraphQLQuery {
  public static let operationName: String = "termsAndConditions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query termsAndConditions { latestTermsAndConditions { __typename id } latestTermsAndConditionsContent }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("latestTermsAndConditions", LatestTermsAndConditions?.self),
      .field("latestTermsAndConditionsContent", String?.self),
    ] }

    /// Get latest Terms and Conditions
    public var latestTermsAndConditions: LatestTermsAndConditions? { __data["latestTermsAndConditions"] }
    /// Get latest Terms and Conditions with LearningAnalytics enabled
    public var latestTermsAndConditionsContent: String? { __data["latestTermsAndConditionsContent"] }

    /// LatestTermsAndConditions
    ///
    /// Parent Type: `TermsAndConditions`
    public struct LatestTermsAndConditions: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.TermsAndConditions }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KnowledgeGraphQLEntities.EncodedId.self),
      ] }

      public var id: KnowledgeGraphQLEntities.EncodedId { __data["id"] }
    }
  }
}
