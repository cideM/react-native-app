// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum IosSubscriptionErrorCode: String, EnumType {
  /// Error Type returned when the receipt could not be authorized. Treat this the same as if a purchase was never made.
  case receiptNotAuthorized = "receiptNotAuthorized"
  /// Error Type returned when the receipt is valid but the subscription has expired
  case subscriptionExpired = "subscriptionExpired"
  /// Error Type returned when the receipt server is not currently available.
  case receiptServerNotAvailable = "receiptServerNotAvailable"
  /// Error Type returned when the receipt could not be authenticated by the IOS App Store
  case receiptNotAuthenticated = "receiptNotAuthenticated"
  /// Error Type returned when an unexpected error ocurrs
  case unexpectedError = "unexpectedError"
}
