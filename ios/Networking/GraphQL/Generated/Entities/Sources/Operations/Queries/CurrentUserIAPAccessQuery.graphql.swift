// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CurrentUserIAPAccessQuery: GraphQLQuery {
  public static let operationName: String = "CurrentUserIAPAccess"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CurrentUserIAPAccess { currentUserCanBuyIosSubscription currentUserActiveIosSubscription { __typename startDate } }"#
    ))

  public init() {}

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentUserCanBuyIosSubscription", Bool.self),
      .field("currentUserActiveIosSubscription", CurrentUserActiveIosSubscription?.self),
    ] }

    /// 	return whether it is possible to buy an iOS In App Purchase Subscription
    public var currentUserCanBuyIosSubscription: Bool { __data["currentUserCanBuyIosSubscription"] }
    /// This will return a valid IOSSubscription object otherwise it will return null otherwise.
    public var currentUserActiveIosSubscription: CurrentUserActiveIosSubscription? { __data["currentUserActiveIosSubscription"] }

    /// CurrentUserActiveIosSubscription
    ///
    /// Parent Type: `IosSubscription`
    public struct CurrentUserActiveIosSubscription: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.IosSubscription }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("startDate", KnowledgeGraphQLEntities.DateTime.self),
      ] }

      /// UTC, ISO 8601 (YYYY-MM-DDThh:mm:ss+00:00)
      public var startDate: KnowledgeGraphQLEntities.DateTime { __data["startDate"] }
    }
  }
}
