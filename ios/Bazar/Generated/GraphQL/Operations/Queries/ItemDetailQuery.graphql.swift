// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class ItemDetailQuery: GraphQLQuery {
    static let operationName: String = "ItemDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ItemDetail($id: ItemId!) { item(id: $id) { __typename id name description category quantity photoImageId addedBy personalNotes purchaseDate purchaseLocation invoiceImageId createdAt updatedAt location { __typename fullPath placeId placeName roomId roomName zoneId zoneName storageId storageName } reminders { __typename id title notes dueDate frequency customIntervalDays createdAt updatedAt } } }"#
      ))

    public var id: ItemId

    public init(id: ItemId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("item", Item?.self, arguments: ["id": .variable("id")]),
      ] }

      /// Get a single item by ID
      var item: Item? { __data["item"] }

      /// Item
      ///
      /// Parent Type: `Item`
      struct Item: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ItemId.self),
          .field("name", BazarGraphQL.ItemName.self),
          .field("description", String.self),
          .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
          .field("quantity", BazarGraphQL.Quantity.self),
          .field("photoImageId", BazarGraphQL.ImageId?.self),
          .field("addedBy", BazarGraphQL.UserTag.self),
          .field("personalNotes", String.self),
          .field("purchaseDate", BazarGraphQL.DateTime?.self),
          .field("purchaseLocation", String.self),
          .field("invoiceImageId", BazarGraphQL.ImageId?.self),
          .field("createdAt", BazarGraphQL.DateTime.self),
          .field("updatedAt", BazarGraphQL.DateTime.self),
          .field("location", Location?.self),
          .field("reminders", [Reminder].self),
        ] }

        /// Item unique identifier
        var id: BazarGraphQL.ItemId { __data["id"] }
        /// Item display name
        var name: BazarGraphQL.ItemName { __data["name"] }
        /// Item description
        var description: String { __data["description"] }
        /// Item category
        var category: GraphQLEnum<BazarGraphQL.ItemCategory> { __data["category"] }
        /// Number of identical items
        var quantity: BazarGraphQL.Quantity { __data["quantity"] }
        /// Photo image identifier
        var photoImageId: BazarGraphQL.ImageId? { __data["photoImageId"] }
        /// User who added this item
        var addedBy: BazarGraphQL.UserTag { __data["addedBy"] }
        /// Personal notes
        var personalNotes: String { __data["personalNotes"] }
        /// Date this item was purchased
        var purchaseDate: BazarGraphQL.DateTime? { __data["purchaseDate"] }
        /// Where the item was purchased (e.g. "Amazon", "Leroy Merlin")
        var purchaseLocation: String { __data["purchaseLocation"] }
        /// Invoice photo image identifier
        var invoiceImageId: BazarGraphQL.ImageId? { __data["invoiceImageId"] }
        /// Creation date
        var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
        /// Last update date
        var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
        /// Resolved location path
        var location: Location? { __data["location"] }
        /// Reminders attached to this item, sorted by dueDate asc
        var reminders: [Reminder] { __data["reminders"] }

        /// Item.Location
        ///
        /// Parent Type: `LocationPath`
        struct Location: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.LocationPath }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("fullPath", String.self),
            .field("placeId", BazarGraphQL.PlaceId.self),
            .field("placeName", BazarGraphQL.PlaceName.self),
            .field("roomId", BazarGraphQL.RoomId.self),
            .field("roomName", BazarGraphQL.RoomName.self),
            .field("zoneId", BazarGraphQL.ZoneId.self),
            .field("zoneName", BazarGraphQL.ZoneName.self),
            .field("storageId", BazarGraphQL.StorageId.self),
            .field("storageName", BazarGraphQL.StorageName.self),
          ] }

          /// Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")
          var fullPath: String { __data["fullPath"] }
          var placeId: BazarGraphQL.PlaceId { __data["placeId"] }
          var placeName: BazarGraphQL.PlaceName { __data["placeName"] }
          var roomId: BazarGraphQL.RoomId { __data["roomId"] }
          var roomName: BazarGraphQL.RoomName { __data["roomName"] }
          var zoneId: BazarGraphQL.ZoneId { __data["zoneId"] }
          var zoneName: BazarGraphQL.ZoneName { __data["zoneName"] }
          var storageId: BazarGraphQL.StorageId { __data["storageId"] }
          var storageName: BazarGraphQL.StorageName { __data["storageName"] }
        }

        /// Item.Reminder
        ///
        /// Parent Type: `Reminder`
        struct Reminder: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Reminder }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BazarGraphQL.ReminderId.self),
            .field("title", BazarGraphQL.ReminderTitle.self),
            .field("notes", String.self),
            .field("dueDate", BazarGraphQL.DateTime.self),
            .field("frequency", GraphQLEnum<BazarGraphQL.ReminderFrequency>?.self),
            .field("customIntervalDays", Int?.self),
            .field("createdAt", BazarGraphQL.DateTime.self),
            .field("updatedAt", BazarGraphQL.DateTime.self),
          ] }

          var id: BazarGraphQL.ReminderId { __data["id"] }
          var title: BazarGraphQL.ReminderTitle { __data["title"] }
          var notes: String { __data["notes"] }
          var dueDate: BazarGraphQL.DateTime { __data["dueDate"] }
          var frequency: GraphQLEnum<BazarGraphQL.ReminderFrequency>? { __data["frequency"] }
          var customIntervalDays: Int? { __data["customIntervalDays"] }
          var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
          var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
        }
      }
    }
  }

}