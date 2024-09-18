// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct FeedbackMobileInfo: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    appPlatform: GraphQLEnum<MobilePlatform>,
    appName: GraphQLEnum<MobileAppName>,
    appVersion: String,
    archiveVersion: Int
  ) {
    __data = InputDict([
      "appPlatform": appPlatform,
      "appName": appName,
      "appVersion": appVersion,
      "archiveVersion": archiveVersion
    ])
  }

  public var appPlatform: GraphQLEnum<MobilePlatform> {
    get { __data["appPlatform"] }
    set { __data["appPlatform"] = newValue }
  }

  public var appName: GraphQLEnum<MobileAppName> {
    get { __data["appName"] }
    set { __data["appName"] = newValue }
  }

  public var appVersion: String {
    get { __data["appVersion"] }
    set { __data["appVersion"] = newValue }
  }

  public var archiveVersion: Int {
    get { __data["archiveVersion"] }
    set { __data["archiveVersion"] = newValue }
  }
}
