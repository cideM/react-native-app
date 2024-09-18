// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum ProductKeyErrorCode: String, EnumType {
  /// The format of the key submitted is not valid.
  case invalidKey = "invalidKey"
  /// The submitted key is expired.
  case expiredKey = "expiredKey"
  /// The submitted key is a marburger bund key and it should be handled in the marburger section of the account page.
  case marburgerKey = "marburgerKey"
  /// The submitted key has not been found.
  case keyNotFound = "keyNotFound"
  /// The submitted key has reached the maximum amount of users.
  case maxUserReached = "maxUserReached"
  /// The submitted key has been used by the current user.
  case alreadyRegistered = "alreadyRegistered"
  /// The current user has already the permission group the key would grant.
  case alreadyGroupMember = "alreadyGroupMember"
  /// The current user has an active subscription and cannot apply the submitted key.
  case activeSubscription = "activeSubscription"
  /// The current user has an active subscription and cannot apply the submitted key.
  case balanceActiveSubscription = "balanceActiveSubscription"
  /// The current user has an active subscription and cannot apply the submitted key.
  case activeSubscriptionLongAccess = "activeSubscriptionLongAccess"
  /// Unexpected error when applying the key.
  case unexpectedErrorWhenApplyingKey = "unexpectedErrorWhenApplyingKey"
}
