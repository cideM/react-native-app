// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Enum to represent the possible status values that Library Archives can have.
public enum ArchiveLibraryUpdateMode: String, EnumType {
  /// This status indicates that the library must be updated. The reason might be that it's faulty and it must be updated.
  case must = "must"
  /// This status indicates that the library archive is +7 weeks older
  case should = "should"
  /// This status indicates that the library archive is not older than 7 weeks.
  case can = "can"
}
