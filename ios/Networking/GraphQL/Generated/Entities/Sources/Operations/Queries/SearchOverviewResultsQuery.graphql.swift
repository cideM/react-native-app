// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchOverviewResultsQuery: GraphQLQuery {
  public static let operationName: String = "SearchOverviewResults"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchOverviewResults($query: String!, $filters: SearchFiltersMediaInput, $first: Int!) { searchPhrasionary(query: $query) { __typename title body etymology synonyms _trackingUuid secondaryTargets { __typename title target { __typename ... on SearchTargetArticle { __typename articleEid particleEid anchorId _trackingUuid } } } } searchArticleContentTree(query: $query, first: $first, compact: true) { __typename totalCount pageInfo { __typename endCursor hasNextPage } edges { __typename cursor node { __typename ...articleNodeFields children { __typename ...articleNodeFields children { __typename ...articleNodeFields children { __typename ...articleNodeFields } } } } } } searchPharmaAgentResults(query: $query, first: $first) { __typename pageInfo { __typename hasNextPage endCursor } edges { __typename node { __typename metadata title details body _trackingUuid target { __typename pharmaAgentId drugId _trackingUuid } } } totalCount } searchAmbossSubstanceResults(query: $query, first: $first, compact: true) { __typename totalCount pageInfo { __typename endCursor hasNextPage } edges { __typename cursor node { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields children { __typename ...ambossSubstanceNodeFields } } } } } } searchGuidelineResults(query: $query, first: $first) { __typename pageInfo { __typename hasNextPage endCursor } edges { __typename node { __typename metadata title details body labels _trackingUuid target { __typename externalUrl _trackingUuid } } } totalCount } searchMediaResults(query: $query, filters: $filters, first: $first) { __typename pageInfo { __typename hasNextPage endCursor } edges { __typename node { __typename metadata title _trackingUuid mediaType { __typename category label } target { __typename mediaEid assetUrl externalAdditionType externalAdditionUrl _trackingUuid } } } totalCount filters { __typename mediaType { __typename value label matchingCount isActive } } } searchInfo(query: $query) { __typename overviewSectionOrder resultInfo { __typename targetView } queryInfo { __typename processedQuery wasAutocorrected } } }"#,
      fragments: [AmbossSubstanceNodeFields.self, ArticleNodeFields.self]
    ))

  public var query: String
  public var filters: GraphQLNullable<SearchFiltersMediaInput>
  public var first: Int

  public init(
    query: String,
    filters: GraphQLNullable<SearchFiltersMediaInput>,
    first: Int
  ) {
    self.query = query
    self.filters = filters
    self.first = first
  }

  public var __variables: Variables? { [
    "query": query,
    "filters": filters,
    "first": first
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchPhrasionary", SearchPhrasionary?.self, arguments: ["query": .variable("query")]),
      .field("searchArticleContentTree", SearchArticleContentTree.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "compact": true
      ]),
      .field("searchPharmaAgentResults", SearchPharmaAgentResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first")
      ]),
      .field("searchAmbossSubstanceResults", SearchAmbossSubstanceResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first"),
        "compact": true
      ]),
      .field("searchGuidelineResults", SearchGuidelineResults.self, arguments: [
        "query": .variable("query"),
        "first": .variable("first")
      ]),
      .field("searchMediaResults", SearchMediaResults.self, arguments: [
        "query": .variable("query"),
        "filters": .variable("filters"),
        "first": .variable("first")
      ]),
      .field("searchInfo", SearchInfo.self, arguments: ["query": .variable("query")]),
    ] }

    public var searchPhrasionary: SearchPhrasionary? { __data["searchPhrasionary"] }
    public var searchArticleContentTree: SearchArticleContentTree { __data["searchArticleContentTree"] }
    public var searchPharmaAgentResults: SearchPharmaAgentResults { __data["searchPharmaAgentResults"] }
    public var searchAmbossSubstanceResults: SearchAmbossSubstanceResults { __data["searchAmbossSubstanceResults"] }
    public var searchGuidelineResults: SearchGuidelineResults { __data["searchGuidelineResults"] }
    public var searchMediaResults: SearchMediaResults { __data["searchMediaResults"] }
    public var searchInfo: SearchInfo { __data["searchInfo"] }

    /// SearchPhrasionary
    ///
    /// Parent Type: `SearchPhrasionary`
    public struct SearchPhrasionary: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPhrasionary }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("body", String?.self),
        .field("etymology", String?.self),
        .field("synonyms", [String].self),
        .field("_trackingUuid", String.self),
        .field("secondaryTargets", [SecondaryTarget].self),
      ] }

      /// Primary designation of the Phrasionary entry.
      public var title: String { __data["title"] }
      /// Definition or explanation of the entry. May include line breaks.
      public var body: String? { __data["body"] }
      /// Subtext to the title. May contain the etymology or abbreviation(s).
      public var etymology: String? { __data["etymology"] }
      /// List of visible synonyms.
      public var synonyms: [String] { __data["synonyms"] }
      /// Unique ID for tracking and analytics.
      public var _trackingUuid: String { __data["_trackingUuid"] }
      /// List of targets with titles.
      public var secondaryTargets: [SecondaryTarget] { __data["secondaryTargets"] }

      /// SearchPhrasionary.SecondaryTarget
      ///
      /// Parent Type: `SecondaryTarget`
      public struct SecondaryTarget: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SecondaryTarget }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("title", String.self),
          .field("target", Target.self),
        ] }

        /// The title of the target.Can contain \<b\>, \<i\> HTML tags.
        public var title: String { __data["title"] }
        public var target: Target { __data["target"] }

        /// SearchPhrasionary.SecondaryTarget.Target
        ///
        /// Parent Type: `SearchTarget`
        public struct Target: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Unions.SearchTarget }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsSearchTargetArticle.self),
          ] }

          public var asSearchTargetArticle: AsSearchTargetArticle? { _asInlineFragment() }

          /// SearchPhrasionary.SecondaryTarget.Target.AsSearchTargetArticle
          ///
          /// Parent Type: `SearchTargetArticle`
          public struct AsSearchTargetArticle: KnowledgeGraphQLEntities.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = SearchOverviewResultsQuery.Data.SearchPhrasionary.SecondaryTarget.Target
            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetArticle }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("articleEid", String.self),
              .field("particleEid", String?.self),
              .field("anchorId", String?.self),
              .field("_trackingUuid", String.self),
            ] }

            /// Article ID.
            public var articleEid: String { __data["articleEid"] }
            /// Particle ID.
            public var particleEid: String? { __data["particleEid"] }
            /// Anchor ID.
            public var anchorId: String? { __data["anchorId"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }
    }

    /// SearchArticleContentTree
    ///
    /// Parent Type: `SearchResultArticleNodeConnection`
    public struct SearchArticleContentTree: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("totalCount", Int.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
      ] }

      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }

      /// SearchArticleContentTree.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("endCursor", String?.self),
          .field("hasNextPage", Bool.self),
        ] }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
      }

      /// SearchArticleContentTree.Edge
      ///
      /// Parent Type: `SearchResultArticleNodeEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination
        public var cursor: String { __data["cursor"] }
        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchArticleContentTree.Edge.Node
        ///
        /// Parent Type: `SearchResultArticleNode`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("children", [Child].self),
            .fragment(ArticleNodeFields.self),
          ] }

          /// List of child Nodes.
          public var children: [Child] { __data["children"] }
          /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var title: String { __data["title"] }
          /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var snippet: String? { __data["snippet"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
          public var target: Target { __data["target"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var articleNodeFields: ArticleNodeFields { _toFragment() }
          }

          /// SearchArticleContentTree.Edge.Node.Child
          ///
          /// Parent Type: `SearchResultArticleNode`
          public struct Child: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("children", [Child].self),
              .fragment(ArticleNodeFields.self),
            ] }

            /// List of child Nodes.
            public var children: [Child] { __data["children"] }
            /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var title: String { __data["title"] }
            /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var snippet: String? { __data["snippet"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
            /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
            public var target: Target { __data["target"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var articleNodeFields: ArticleNodeFields { _toFragment() }
            }

            /// SearchArticleContentTree.Edge.Node.Child.Child
            ///
            /// Parent Type: `SearchResultArticleNode`
            public struct Child: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("children", [Child].self),
                .fragment(ArticleNodeFields.self),
              ] }

              /// List of child Nodes.
              public var children: [Child] { __data["children"] }
              /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var title: String { __data["title"] }
              /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var snippet: String? { __data["snippet"] }
              /// Unique ID for tracking and analytics.
              public var _trackingUuid: String { __data["_trackingUuid"] }
              /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
              public var target: Target { __data["target"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var articleNodeFields: ArticleNodeFields { _toFragment() }
              }

              /// SearchArticleContentTree.Edge.Node.Child.Child.Child
              ///
              /// Parent Type: `SearchResultArticleNode`
              public struct Child: KnowledgeGraphQLEntities.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultArticleNode }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(ArticleNodeFields.self),
                ] }

                /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var title: String { __data["title"] }
                /// Content snippet with a preview of the matched Article text. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var snippet: String? { __data["snippet"] }
                /// Unique ID for tracking and analytics.
                public var _trackingUuid: String { __data["_trackingUuid"] }
                /// Target of the Node, specified by Article, Section and ID of the particular element, as applicable.
                public var target: Target { __data["target"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var articleNodeFields: ArticleNodeFields { _toFragment() }
                }

                public typealias Target = ArticleNodeFields.Target
              }

              public typealias Target = ArticleNodeFields.Target
            }

            public typealias Target = ArticleNodeFields.Target
          }

          public typealias Target = ArticleNodeFields.Target
        }
      }
    }

    /// SearchPharmaAgentResults
    ///
    /// Parent Type: `SearchResultPharmaAgentsConnection`
    public struct SearchPharmaAgentResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
        .field("totalCount", Int.self),
      ] }

      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }
      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }

      /// SearchPharmaAgentResults.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// SearchPharmaAgentResults.Edge
      ///
      /// Parent Type: `SearchResultPharmaAgentsEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node?.self),
        ] }

        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchPharmaAgentResults.Edge.Node
        ///
        /// Parent Type: `SearchResultPharmaAgent`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgent }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("details", [String?]?.self),
            .field("body", String?.self),
            .field("_trackingUuid", String.self),
            .field("target", Target.self),
          ] }

          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Usually a text content of the Search Result. Can contain \<b\>, \<i\> HTML tags.
          public var body: String? { __data["body"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Pharma Agent target.
          public var target: Target { __data["target"] }

          /// SearchPharmaAgentResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetPharmaAgent`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetPharmaAgent }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("pharmaAgentId", String.self),
              .field("drugId", String.self),
              .field("_trackingUuid", String.self),
            ] }

            /// Pharma Agent ID.
            public var pharmaAgentId: String { __data["pharmaAgentId"] }
            /// Drug ID.
            public var drugId: String { __data["drugId"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }
    }

    /// SearchAmbossSubstanceResults
    ///
    /// Parent Type: `SearchResultAmbossSubstanceNodeConnection`
    public struct SearchAmbossSubstanceResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("totalCount", Int.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
      ] }

      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }

      /// SearchAmbossSubstanceResults.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("endCursor", String?.self),
          .field("hasNextPage", Bool.self),
        ] }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
      }

      /// SearchAmbossSubstanceResults.Edge
      ///
      /// Parent Type: `SearchResultAmbossSubstanceNodeEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("cursor", String.self),
          .field("node", Node?.self),
        ] }

        /// A cursor for use in pagination
        public var cursor: String { __data["cursor"] }
        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchAmbossSubstanceResults.Edge.Node
        ///
        /// Parent Type: `SearchResultAmbossSubstanceNode`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("children", [Child].self),
            .fragment(AmbossSubstanceNodeFields.self),
          ] }

          /// List of child Nodes.
          public var children: [Child] { __data["children"] }
          /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
          public var title: String { __data["title"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
          public var target: Target { __data["target"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
          }

          /// SearchAmbossSubstanceResults.Edge.Node.Child
          ///
          /// Parent Type: `SearchResultAmbossSubstanceNode`
          public struct Child: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("children", [Child].self),
              .fragment(AmbossSubstanceNodeFields.self),
            ] }

            /// List of child Nodes.
            public var children: [Child] { __data["children"] }
            /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
            public var title: String { __data["title"] }
            /// List of details. Can contain \<b\>, \<i\> HTML tags.
            public var details: [String?]? { __data["details"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
            /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
            public var target: Target { __data["target"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
            }

            /// SearchAmbossSubstanceResults.Edge.Node.Child.Child
            ///
            /// Parent Type: `SearchResultAmbossSubstanceNode`
            public struct Child: KnowledgeGraphQLEntities.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("children", [Child].self),
                .fragment(AmbossSubstanceNodeFields.self),
              ] }

              /// List of child Nodes.
              public var children: [Child] { __data["children"] }
              /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
              public var title: String { __data["title"] }
              /// List of details. Can contain \<b\>, \<i\> HTML tags.
              public var details: [String?]? { __data["details"] }
              /// Unique ID for tracking and analytics.
              public var _trackingUuid: String { __data["_trackingUuid"] }
              /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
              public var target: Target { __data["target"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
              }

              /// SearchAmbossSubstanceResults.Edge.Node.Child.Child.Child
              ///
              /// Parent Type: `SearchResultAmbossSubstanceNode`
              public struct Child: KnowledgeGraphQLEntities.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(AmbossSubstanceNodeFields.self),
                ] }

                /// Title of the Node. May be styled with `<b>` and `<i>` tags for bold and italic, respectively.
                public var title: String { __data["title"] }
                /// List of details. Can contain \<b\>, \<i\> HTML tags.
                public var details: [String?]? { __data["details"] }
                /// Unique ID for tracking and analytics.
                public var _trackingUuid: String { __data["_trackingUuid"] }
                /// Target of the Node, specified by AmbossSubstance, Section and ID of the particular element, as applicable.
                public var target: Target { __data["target"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var ambossSubstanceNodeFields: AmbossSubstanceNodeFields { _toFragment() }
                }

                public typealias Target = AmbossSubstanceNodeFields.Target
              }

              public typealias Target = AmbossSubstanceNodeFields.Target
            }

            public typealias Target = AmbossSubstanceNodeFields.Target
          }

          public typealias Target = AmbossSubstanceNodeFields.Target
        }
      }
    }

    /// SearchGuidelineResults
    ///
    /// Parent Type: `SearchResultGuidelinesConnection`
    public struct SearchGuidelineResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
        .field("totalCount", Int.self),
      ] }

      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }
      /// Number of results
      public var totalCount: Int { __data["totalCount"] }

      /// SearchGuidelineResults.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// SearchGuidelineResults.Edge
      ///
      /// Parent Type: `SearchResultGuidelinesEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node?.self),
        ] }

        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchGuidelineResults.Edge.Node
        ///
        /// Parent Type: `SearchResultGuideline`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultGuideline }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("details", [String?]?.self),
            .field("body", String?.self),
            .field("labels", [String?]?.self),
            .field("_trackingUuid", String.self),
            .field("target", Target?.self),
          ] }

          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          /// List of details. Can contain \<b\>, \<i\> HTML tags.
          public var details: [String?]? { __data["details"] }
          /// Usually a text content of the Search Result. Can contain \<b\>, \<i\> HTML tags.
          public var body: String? { __data["body"] }
          /// List of labels. For example: vorklinik, klinik, arzt.
          public var labels: [String?]? { __data["labels"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          public var target: Target? { __data["target"] }

          /// SearchGuidelineResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetExternalUrl`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetExternalUrl }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("externalUrl", String.self),
              .field("_trackingUuid", String.self),
            ] }

            /// The URL of the external resource.
            public var externalUrl: String { __data["externalUrl"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }
    }

    /// SearchMediaResults
    ///
    /// Parent Type: `SearchResultMediaConnection`
    public struct SearchMediaResults: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("edges", [Edge?].self),
        .field("totalCount", Int.self),
        .field("filters", Filters.self),
      ] }

      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// Contains the nodes in this connection.
      public var edges: [Edge?] { __data["edges"] }
      /// Total number of available results.
      public var totalCount: Int { __data["totalCount"] }
      /// Media filters applied and/or suggested for the query.
      public var filters: Filters { __data["filters"] }

      /// SearchMediaResults.PageInfo
      ///
      /// Parent Type: `SearchPageInfo`
      public struct PageInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
      }

      /// SearchMediaResults.Edge
      ///
      /// Parent Type: `SearchResultMediaEdge`
      public struct Edge: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("node", Node?.self),
        ] }

        /// The item at the end of the edge
        public var node: Node? { __data["node"] }

        /// SearchMediaResults.Edge.Node
        ///
        /// Parent Type: `SearchResultMedia`
        public struct Node: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMedia }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("metadata", String?.self),
            .field("title", String.self),
            .field("_trackingUuid", String.self),
            .field("mediaType", MediaType.self),
            .field("target", Target.self),
          ] }

          /// The metadata contains tracking information that should be forwarded to the tracking events.
          public var metadata: String? { __data["metadata"] }
          /// Title of the Search Result. Constitutes the primary label for the main target. Can contain \<b\>, \<i\> HTML tags.
          public var title: String { __data["title"] }
          /// Unique ID for tracking and analytics.
          public var _trackingUuid: String { __data["_trackingUuid"] }
          public var mediaType: MediaType { __data["mediaType"] }
          public var target: Target { __data["target"] }

          /// SearchMediaResults.Edge.Node.MediaType
          ///
          /// Parent Type: `SearchResultMediaType`
          public struct MediaType: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchResultMediaType }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("category", GraphQLEnum<KnowledgeGraphQLEntities.SearchMediaTypeCategory>.self),
              .field("label", String.self),
            ] }

            /// Generic category of the Media type, to be represented with the appropriate Icon.
            public var category: GraphQLEnum<KnowledgeGraphQLEntities.SearchMediaTypeCategory> { __data["category"] }
            /// Localized text label for the specific Media type.
            public var label: String { __data["label"] }
          }

          /// SearchMediaResults.Edge.Node.Target
          ///
          /// Parent Type: `SearchTargetMedia`
          public struct Target: KnowledgeGraphQLEntities.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchTargetMedia }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("mediaEid", String.self),
              .field("assetUrl", String.self),
              .field("externalAdditionType", GraphQLEnum<KnowledgeGraphQLEntities.SearchTargetMediaAdditionType>?.self),
              .field("externalAdditionUrl", String?.self),
              .field("_trackingUuid", String.self),
            ] }

            /// Media ID.
            public var mediaEid: String { __data["mediaEid"] }
            /// The source URL of the media asset.
            public var assetUrl: String { __data["assetUrl"] }
            public var externalAdditionType: GraphQLEnum<KnowledgeGraphQLEntities.SearchTargetMediaAdditionType>? { __data["externalAdditionType"] }
            /// The URL to the external addition. Only used if the media is an external addition.
            public var externalAdditionUrl: String? { __data["externalAdditionUrl"] }
            /// Unique ID for tracking and analytics.
            public var _trackingUuid: String { __data["_trackingUuid"] }
          }
        }
      }

      /// SearchMediaResults.Filters
      ///
      /// Parent Type: `SearchFiltersMedia`
      public struct Filters: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchFiltersMedia }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("mediaType", [MediaType].self),
        ] }

        /// List of Media type filters.
        public var mediaType: [MediaType] { __data["mediaType"] }

        /// SearchMediaResults.Filters.MediaType
        ///
        /// Parent Type: `SearchFilterValue`
        public struct MediaType: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchFilterValue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("value", String.self),
            .field("label", String.self),
            .field("matchingCount", Int?.self),
            .field("isActive", Bool.self),
          ] }

          /// Internal identifier of the filter value.
          public var value: String { __data["value"] }
          /// Localized label for the filter value.
          public var label: String { __data["label"] }
          /// Total number of results that match the filter.
          public var matchingCount: Int? { __data["matchingCount"] }
          /// Current state of the filter.
          public var isActive: Bool { __data["isActive"] }
        }
      }
    }

    /// SearchInfo
    ///
    /// Parent Type: `SearchInfo`
    public struct SearchInfo: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchInfo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("overviewSectionOrder", [GraphQLEnum<KnowledgeGraphQLEntities.SearchResultType>].self),
        .field("resultInfo", ResultInfo.self),
        .field("queryInfo", QueryInfo.self),
      ] }

      public var overviewSectionOrder: [GraphQLEnum<KnowledgeGraphQLEntities.SearchResultType>] { __data["overviewSectionOrder"] }
      public var resultInfo: ResultInfo { __data["resultInfo"] }
      public var queryInfo: QueryInfo { __data["queryInfo"] }

      /// SearchInfo.ResultInfo
      ///
      /// Parent Type: `SearchInfoResultData`
      public struct ResultInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchInfoResultData }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("targetView", GraphQLEnum<KnowledgeGraphQLEntities.SearchResultsView>?.self),
        ] }

        /// Tab to switch to on the Search Results Page, if specified.
        public var targetView: GraphQLEnum<KnowledgeGraphQLEntities.SearchResultsView>? { __data["targetView"] }
      }

      /// SearchInfo.QueryInfo
      ///
      /// Parent Type: `SearchInfoQueryData`
      public struct QueryInfo: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.SearchInfoQueryData }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("processedQuery", String.self),
          .field("wasAutocorrected", Bool.self),
        ] }

        public var processedQuery: String { __data["processedQuery"] }
        public var wasAutocorrected: Bool { __data["wasAutocorrected"] }
      }
    }
  }
}
