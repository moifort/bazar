// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Target location for moving an item (zone or storage, mutually exclusive)
  struct MoveItemInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      storageId: GraphQLNullable<StorageId> = nil,
      zoneId: GraphQLNullable<ZoneId> = nil
    ) {
      __data = InputDict([
        "storageId": storageId,
        "zoneId": zoneId
      ])
    }

    /// Move to a storage
    var storageId: GraphQLNullable<StorageId> {
      get { __data["storageId"] }
      set { __data["storageId"] = newValue }
    }

    /// Move to a zone (no storage)
    var zoneId: GraphQLNullable<ZoneId> {
      get { __data["zoneId"] }
      set { __data["zoneId"] = newValue }
    }
  }

}