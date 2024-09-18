// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PharmaAgentQuery: GraphQLQuery {
  public static let operationName: String = "pharmaAgent"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query pharmaAgent($id: ID!) { ambossSubstance(id: $id) { __typename id name drugs { __typename id name atcLabel vendor prescriptions applicationForms priceAndPackageInfo(sorting: Ascending) { __typename packageSize amount unit pharmacyPrice recommendedRetailPrice } } } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("ambossSubstance", AmbossSubstance.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get Amboss Substance by ID.
    public var ambossSubstance: AmbossSubstance { __data["ambossSubstance"] }

    /// AmbossSubstance
    ///
    /// Parent Type: `AmbossSubstance`
    public struct AmbossSubstance: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.AmbossSubstance }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KnowledgeGraphQLEntities.ID.self),
        .field("name", String.self),
        .field("drugs", [Drug].self),
      ] }

      public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var drugs: [Drug] { __data["drugs"] }

      /// AmbossSubstance.Drug
      ///
      /// Parent Type: `PharmaDrug`
      public struct Drug: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaDrug }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", KnowledgeGraphQLEntities.ID.self),
          .field("name", String.self),
          .field("atcLabel", String.self),
          .field("vendor", String.self),
          .field("prescriptions", [GraphQLEnum<KnowledgeGraphQLEntities.PharmaPrescriptionStatus>].self),
          .field("applicationForms", [GraphQLEnum<KnowledgeGraphQLEntities.PharmaApplicationForm>].self),
          .field("priceAndPackageInfo", [PriceAndPackageInfo].self, arguments: ["sorting": "Ascending"]),
        ] }

        public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
        public var name: String { __data["name"] }
        /// drug related atc group label
        public var atcLabel: String { __data["atcLabel"] }
        public var vendor: String { __data["vendor"] }
        public var prescriptions: [GraphQLEnum<KnowledgeGraphQLEntities.PharmaPrescriptionStatus>] { __data["prescriptions"] }
        /// A list of editorially curated application forms. We convert every unique
        /// combination of IFAP application form, location and way to a single list of our
        /// own application form strings.
        public var applicationForms: [GraphQLEnum<KnowledgeGraphQLEntities.PharmaApplicationForm>] { __data["applicationForms"] }
        public var priceAndPackageInfo: [PriceAndPackageInfo] { __data["priceAndPackageInfo"] }

        /// AmbossSubstance.Drug.PriceAndPackageInfo
        ///
        /// Parent Type: `PriceAndPackage`
        public struct PriceAndPackageInfo: KnowledgeGraphQLEntities.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PriceAndPackage }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("packageSize", GraphQLEnum<KnowledgeGraphQLEntities.NormedPackageSize>?.self),
            .field("amount", String.self),
            .field("unit", String.self),
            .field("pharmacyPrice", String?.self),
            .field("recommendedRetailPrice", String?.self),
          ] }

          /// IFAP does not always include a package size value, as such this can be empty.
          public var packageSize: GraphQLEnum<KnowledgeGraphQLEntities.NormedPackageSize>? { __data["packageSize"] }
          public var amount: String { __data["amount"] }
          public var unit: String { __data["unit"] }
          public var pharmacyPrice: String? { __data["pharmacyPrice"] }
          public var recommendedRetailPrice: String? { __data["recommendedRetailPrice"] }
        }
      }
    }
  }
}
