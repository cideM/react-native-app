// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// PriceAndPackageSorting can be used to determine the order in which price and
/// package information for a branded drug is returned.
///
/// - Ascending: Sorts by package size (N1 first, N2 second, and so on), then by
/// pharmacy price and then by recommended retail price.
/// - Mixed: Internally, results are put into groups, where each group is unique and
/// sorted in the "Ascending" manner. For branded drugs with logs of different price
/// and package values, you'll get something like "N1,N2,N3,N1,N2,N3,KTP,KTP" (only
/// showing package sizes) where the groups, used by the resolver internally, were
/// "[N1,N2,N3],[N1,N2,N3],[KTP],[KTP]"
public enum PriceAndPackageSorting: String, EnumType {
  case ascending = "Ascending"
  case mixed = "Mixed"
}
