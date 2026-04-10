// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for creating a new storage spot
  struct CreateStorageInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      name: StorageName,
      zoneId: ZoneId
    ) {
      __data = InputDict([
        "name": name,
        "zoneId": zoneId
      ])
    }

    /// Storage name
    var name: StorageName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Parent zone
    var zoneId: ZoneId {
      get { __data["zoneId"] }
      set { __data["zoneId"] = newValue }
    }
  }

}