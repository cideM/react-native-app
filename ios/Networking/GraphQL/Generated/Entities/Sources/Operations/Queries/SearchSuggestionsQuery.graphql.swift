// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchSuggestionsQuery: GraphQLQuery {
  public static let operationName: String = "SearchSuggestions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchSuggestions($queryParam: String!, $limit: Int!, $types: [SearchResultType]) { searchSuggestions(query: $queryParam, limit: $limit, types: $types) { __typename text value ... on SearchSuggestionQuery { metadata } ... on SearchSuggestionInstantResult { metadata target { __typename ... on SearchTargetArticle { articleEid particleEid anchorId } ... on SearchTargetPharmaAgent { pharmaAgentId drugId } ... on SearchTargetPharmaMonograph { pharmaMonographId } } } } }"#
    ))

  public var queryParam: String
  public var limit: Int
  public var types: GraphQLNullable<[GraphQLEnum<SearchResultType>?]>

  public init(
    queryParam: String,
    limit: Int,
    types: GraphQLNullable<[GraphQLEnum<SearchResultType>?]>
  ) {
    self.queryParam = queryParam
    self.limit = limit
    self.types = types
  }

  public var __variables: Variables? { [
    "queryParam": queryParam,
    "limit": limit,
    "types": types
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchSuggestions", [SearchSuggestion?].self, arguments: [
        "query": .variable("queryParam"),
        "limit": .variable("limit"),
        "types": .variable("types")
      ]),
    ] }

    /// Suggestions for search query input, comprising Topical Instant Results, Instant Results and Completions.
    public var searchSuggestions: [SearchSuggestion?] { __data["searchSuggestions"] }

    /// SearchSuggestion
    ///
    /// Parent Type: `SearchSuggestionBase`
    public struct SearchSuggestion: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Interfaces.SearchSuggestionBase }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("text", String.self),
        .field("value", String.self),
        .inlineFragment(AsSearchSuggestionQuery.self),
        .inlineFragment(AsSearchSuggestionInstantResult.self),
      ] }

      /// The text of the suggestion with highlighting. Can contain \<b\> HTML tags.
      public var text: String { __data["text"] }
      /// The text of the suggestion that is shown to users.
      public var value: String { __data["value"] }

      public var asSearchSuggestionQuery: AsSearchSuggestionQuery? { _asInlineFragment() }
      public var asSearchSuggestionInstantResult: AsSearchSuggestionInstantResult? { _asInlineFragment() }

      /// SearchSuggestion.AsSearchSuggestionQuery
      ///
      /// Parent Type: `SearchSuggestionQuery`
      public struct AsSearchSuggestionQuery: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SearchSuggestionsQuery.Data.SearchSuggestion
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchSuggestionQuery }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("metadata", String?.self),
        ] }

        /// The metadata of the suggestion engine.
        public var metadata: String? { __data["metadata"] }
        /// The text of the suggestion with highlighting. Can contain \<b\> HTML tags.
        public var text: String { __data["text"] }
        /// The text of the suggestion that is shown to users.
        public var value: String { __data["value"] }
      }

      /// SearchSuggestion.AsSearchSuggestionInstantResult
      ///
      /// Parent Type: `SearchSuggestionInstantResult`
      public struct AsSearchSuggestionInstantResult: KnowledgeGraphQLEntities.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SearchSuggestionsQuery.Data.SearchSuggestion
        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchSuggestionInstantResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("metadata", String?.self),
          .field("target", Target?.self),
        ] }

        /// The metadata of the suggestion engine.
        public var metadata: String? { __data["metadata"] }
        public var target: Target? { __data["target"] }
        /// The text of the suggestion with highlighting. Can contain \<b\> HTML tags.
        public var text: String { __data["text"] }
        /// The text of the suggestion that is shown to users.
        public var value: String { __data["value"] }

        /// SearchSuggestion.AsSearchSuggestionInstantResult.Target
        ///
        /// Parent Type: `SearchTarget`
        public struct Target: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.SearchTarget }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsSearchTargetArticle.self),
            .inlineFragment(AsSearchTargetPharmaAgent.self),
            .inlineFragment(AsSearchTargetPharmaMonograph.self),
          ] }

          public var asSearchTargetArticle: AsSearchTargetArticle? { _asInlineFragment() }
          public var asSearchTargetPharmaAgent: AsSearchTargetPharmaAgent? { _asInlineFragment() }
          public var asSearchTargetPharmaMonograph: AsSearchTargetPharmaMonograph? { _asInlineFragment() }

          /// SearchSuggestion.AsSearchSuggestionInstantResult.Target.AsSearchTargetArticle
          ///
          /// Parent Type: `SearchTargetArticle`
          public struct AsSearchTargetArticle: KnowledgeGraphQLEntities.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = SearchSuggestionsQuery.Data.SearchSuggestion.AsSearchSuggestionInstantResult.Target
            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetArticle }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("articleEid", String.self),
              .field("particleEid", String?.self),
              .field("anchorId", String?.self),
            ] }

            /// Article ID.
            public var articleEid: String { __data["articleEid"] }
            /// Particle ID.
            public var particleEid: String? { __data["particleEid"] }
            /// Anchor ID.
            public var anchorId: String? { __data["anchorId"] }
          }

          /// SearchSuggestion.AsSearchSuggestionInstantResult.Target.AsSearchTargetPharmaAgent
          ///
          /// Parent Type: `SearchTargetPharmaAgent`
          public struct AsSearchTargetPharmaAgent: KnowledgeGraphQLEntities.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = SearchSuggestionsQuery.Data.SearchSuggestion.AsSearchSuggestionInstantResult.Target
            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetPharmaAgent }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("pharmaAgentId", String.self),
              .field("drugId", String.self),
            ] }

            /// Pharma Agent ID.
            public var pharmaAgentId: String { __data["pharmaAgentId"] }
            /// Drug ID.
            public var drugId: String { __data["drugId"] }
          }

          /// SearchSuggestion.AsSearchSuggestionInstantResult.Target.AsSearchTargetPharmaMonograph
          ///
          /// Parent Type: `SearchTargetPharmaMonograph`
          public struct AsSearchTargetPharmaMonograph: KnowledgeGraphQLEntities.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = SearchSuggestionsQuery.Data.SearchSuggestion.AsSearchSuggestionInstantResult.Target
            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetPharmaMonograph }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("pharmaMonographId", String.self),
            ] }

            /// Pharma Monograph ID.
            public var pharmaMonographId: String { __data["pharmaMonographId"] }
          }
        }
      }
    }
  }
}
