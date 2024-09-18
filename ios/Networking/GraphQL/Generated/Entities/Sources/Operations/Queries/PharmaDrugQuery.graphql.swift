// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PharmaDrugQuery: GraphQLQuery {
  public static let operationName: String = "pharmaDrug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query pharmaDrug($id: ID!, $sorting: PriceAndPackageSorting!) { pharmaDrug(id: $id) { __typename id name atcLabel agentId applicationForms brandName dosageForms patientPackageInsertUrl prescribingInformationUrl prescriptions publishedAt sections { __typename id title position text } vendor priceAndPackageInfo(sorting: $sorting) { __typename packageSize amount unit pharmacyPrice recommendedRetailPrice } } }"#
    ))

  public var id: ID
  public var sorting: GraphQLEnum<PriceAndPackageSorting>

  public init(
    id: ID,
    sorting: GraphQLEnum<PriceAndPackageSorting>
  ) {
    self.id = id
    self.sorting = sorting
  }

  public var __variables: Variables? { [
    "id": id,
    "sorting": sorting
  ] }

  public struct Data: KnowledgeGraphQLEntities.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("pharmaDrug", PharmaDrug.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get Pharma Drug by ID.
    public var pharmaDrug: PharmaDrug { __data["pharmaDrug"] }

    /// PharmaDrug
    ///
    /// Parent Type: `PharmaDrug`
    public struct PharmaDrug: KnowledgeGraphQLEntities.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaDrug }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KnowledgeGraphQLEntities.ID.self),
        .field("name", String.self),
        .field("atcLabel", String.self),
        .field("agentId", KnowledgeGraphQLEntities.ID.self),
        .field("applicationForms", [GraphQLEnum<KnowledgeGraphQLEntities.PharmaApplicationForm>].self),
        .field("brandName", String.self),
        .field("dosageForms", [String].self),
        .field("patientPackageInsertUrl", String?.self),
        .field("prescribingInformationUrl", String?.self),
        .field("prescriptions", [GraphQLEnum<KnowledgeGraphQLEntities.PharmaPrescriptionStatus>].self),
        .field("publishedAt", KnowledgeGraphQLEntities.DateTime.self),
        .field("sections", [Section].self),
        .field("vendor", String.self),
        .field("priceAndPackageInfo", [PriceAndPackageInfo].self, arguments: ["sorting": .variable("sorting")]),
      ] }

      public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
      public var name: String { __data["name"] }
      /// drug related atc group label
      public var atcLabel: String { __data["atcLabel"] }
      /// Amboss substance id
      public var agentId: KnowledgeGraphQLEntities.ID { __data["agentId"] }
      /// A list of editorially curated application forms. We convert every unique
      /// combination of IFAP application form, location and way to a single list of our
      /// own application form strings.
      public var applicationForms: [GraphQLEnum<KnowledgeGraphQLEntities.PharmaApplicationForm>] { __data["applicationForms"] }
      public var brandName: String { __data["brandName"] }
      public var dosageForms: [String] { __data["dosageForms"] }
      /// URL for downloading a PDF containing 'Beipackzettel'
      public var patientPackageInsertUrl: String? { __data["patientPackageInsertUrl"] }
      /// URL for downloading a PDF containing 'Fachinformationen'
      public var prescribingInformationUrl: String? { __data["prescribingInformationUrl"] }
      public var prescriptions: [GraphQLEnum<KnowledgeGraphQLEntities.PharmaPrescriptionStatus>] { __data["prescriptions"] }
      public var publishedAt: KnowledgeGraphQLEntities.DateTime { __data["publishedAt"] }
      /// Sections specific to the drug
      public var sections: [Section] { __data["sections"] }
      public var vendor: String { __data["vendor"] }
      public var priceAndPackageInfo: [PriceAndPackageInfo] { __data["priceAndPackageInfo"] }

      /// PharmaDrug.Section
      ///
      /// Parent Type: `PharmaText`
      public struct Section: KnowledgeGraphQLEntities.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KnowledgeGraphQLEntities.Objects.PharmaText }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", KnowledgeGraphQLEntities.ID.self),
          .field("title", String.self),
          .field("position", Int.self),
          .field("text", String.self),
        ] }

        public var id: KnowledgeGraphQLEntities.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var position: Int { __data["position"] }
        public var text: String { __data["text"] }
      }

      /// PharmaDrug.PriceAndPackageInfo
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
