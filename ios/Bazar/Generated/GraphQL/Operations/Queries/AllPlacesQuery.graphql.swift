// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class AllPlacesQuery: GraphQLQuery {
    static let operationName: String = "AllPlaces"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AllPlaces { places { __typename id name icon order rooms { __typename id placeId name icon order zones { __typename id roomId name order storages { __typename id zoneId name order } } } } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("places", [Place].self),
      ] }

      /// All places with nested rooms, zones, and storages
      var places: [Place] { __data["places"] }

      /// Place
      ///
      /// Parent Type: `Place`
      struct Place: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Place }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.PlaceId.self),
          .field("name", BazarGraphQL.PlaceName.self),
          .field("icon", String?.self),
          .field("order", Int.self),
          .field("rooms", [Room].self),
        ] }

        /// Place unique identifier
        var id: BazarGraphQL.PlaceId { __data["id"] }
        /// Place display name
        var name: BazarGraphQL.PlaceName { __data["name"] }
        /// Optional emoji icon
        var icon: String? { __data["icon"] }
        /// Sort order
        var order: Int { __data["order"] }
        /// Rooms in this place
        var rooms: [Room] { __data["rooms"] }

        /// Place.Room
        ///
        /// Parent Type: `Room`
        struct Room: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Room }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BazarGraphQL.RoomId.self),
            .field("placeId", BazarGraphQL.PlaceId.self),
            .field("name", BazarGraphQL.RoomName.self),
            .field("icon", String?.self),
            .field("order", Int.self),
            .field("zones", [Zone].self),
          ] }

          /// Room unique identifier
          var id: BazarGraphQL.RoomId { __data["id"] }
          /// Parent place identifier
          var placeId: BazarGraphQL.PlaceId { __data["placeId"] }
          /// Room display name
          var name: BazarGraphQL.RoomName { __data["name"] }
          /// Optional emoji icon
          var icon: String? { __data["icon"] }
          /// Sort order
          var order: Int { __data["order"] }
          /// Zones in this room
          var zones: [Zone] { __data["zones"] }

          /// Place.Room.Zone
          ///
          /// Parent Type: `Zone`
          struct Zone: BazarGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Zone }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", BazarGraphQL.ZoneId.self),
              .field("roomId", BazarGraphQL.RoomId.self),
              .field("name", BazarGraphQL.ZoneName.self),
              .field("order", Int.self),
              .field("storages", [Storage].self),
            ] }

            /// Zone unique identifier
            var id: BazarGraphQL.ZoneId { __data["id"] }
            /// Parent room identifier
            var roomId: BazarGraphQL.RoomId { __data["roomId"] }
            /// Zone display name
            var name: BazarGraphQL.ZoneName { __data["name"] }
            /// Sort order
            var order: Int { __data["order"] }
            /// Storage spots in this zone
            var storages: [Storage] { __data["storages"] }

            /// Place.Room.Zone.Storage
            ///
            /// Parent Type: `Storage`
            struct Storage: BazarGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Storage }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", BazarGraphQL.StorageId.self),
                .field("zoneId", BazarGraphQL.ZoneId.self),
                .field("name", BazarGraphQL.StorageName.self),
                .field("order", Int.self),
              ] }

              /// Storage unique identifier
              var id: BazarGraphQL.StorageId { __data["id"] }
              /// Parent zone identifier
              var zoneId: BazarGraphQL.ZoneId { __data["zoneId"] }
              /// Storage display name
              var name: BazarGraphQL.StorageName { __data["name"] }
              /// Sort order
              var order: Int { __data["order"] }
            }
          }
        }
      }
    }
  }

}