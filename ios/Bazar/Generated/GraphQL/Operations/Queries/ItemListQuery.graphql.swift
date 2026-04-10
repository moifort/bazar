// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class ItemListQuery: GraphQLQuery {
    static let operationName: String = "ItemList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ItemList($category: ItemCategory, $placeId: PlaceId, $roomId: RoomId, $search: String, $sort: ItemSort, $order: SortOrder, $offset: Int, $limit: Int) { items( category: $category placeId: $placeId roomId: $roomId search: $search sort: $sort order: $order offset: $offset limit: $limit ) { __typename items { __typename id name category quantity photoImageId addedBy createdAt location { __typename fullPath placeId placeName roomId roomName } } totalCount hasMore } }"#
      ))

    public var category: GraphQLNullable<GraphQLEnum<ItemCategory>>
    public var placeId: GraphQLNullable<PlaceId>
    public var roomId: GraphQLNullable<RoomId>
    public var search: GraphQLNullable<String>
    public var sort: GraphQLNullable<GraphQLEnum<ItemSort>>
    public var order: GraphQLNullable<GraphQLEnum<SortOrder>>
    public var offset: GraphQLNullable<Int>
    public var limit: GraphQLNullable<Int>

    public init(
      category: GraphQLNullable<GraphQLEnum<ItemCategory>>,
      placeId: GraphQLNullable<PlaceId>,
      roomId: GraphQLNullable<RoomId>,
      search: GraphQLNullable<String>,
      sort: GraphQLNullable<GraphQLEnum<ItemSort>>,
      order: GraphQLNullable<GraphQLEnum<SortOrder>>,
      offset: GraphQLNullable<Int>,
      limit: GraphQLNullable<Int>
    ) {
      self.category = category
      self.placeId = placeId
      self.roomId = roomId
      self.search = search
      self.sort = sort
      self.order = order
      self.offset = offset
      self.limit = limit
    }

    public var __variables: Variables? { [
      "category": category,
      "placeId": placeId,
      "roomId": roomId,
      "search": search,
      "sort": sort,
      "order": order,
      "offset": offset,
      "limit": limit
    ] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("items", Items.self, arguments: [
          "category": .variable("category"),
          "placeId": .variable("placeId"),
          "roomId": .variable("roomId"),
          "search": .variable("search"),
          "sort": .variable("sort"),
          "order": .variable("order"),
          "offset": .variable("offset"),
          "limit": .variable("limit")
        ]),
      ] }

      /// List items with optional filters and pagination
      var items: Items { __data["items"] }

      /// Items
      ///
      /// Parent Type: `Items`
      struct Items: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Items }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("items", [Item].self),
          .field("totalCount", Int.self),
          .field("hasMore", Bool.self),
        ] }

        var items: [Item] { __data["items"] }
        /// Total number of matching items
        var totalCount: Int { __data["totalCount"] }
        /// Whether more items are available
        var hasMore: Bool { __data["hasMore"] }

        /// Items.Item
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
            .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
            .field("quantity", BazarGraphQL.Quantity.self),
            .field("photoImageId", BazarGraphQL.ImageId?.self),
            .field("addedBy", BazarGraphQL.UserTag.self),
            .field("createdAt", BazarGraphQL.DateTime.self),
            .field("location", Location?.self),
          ] }

          /// Item unique identifier
          var id: BazarGraphQL.ItemId { __data["id"] }
          /// Item display name
          var name: BazarGraphQL.ItemName { __data["name"] }
          /// Item category
          var category: GraphQLEnum<BazarGraphQL.ItemCategory> { __data["category"] }
          /// Number of identical items
          var quantity: BazarGraphQL.Quantity { __data["quantity"] }
          /// Photo image identifier
          var photoImageId: BazarGraphQL.ImageId? { __data["photoImageId"] }
          /// User who added this item
          var addedBy: BazarGraphQL.UserTag { __data["addedBy"] }
          /// Creation date
          var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
          /// Resolved location path
          var location: Location? { __data["location"] }

          /// Items.Item.Location
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
            ] }

            /// Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")
            var fullPath: String { __data["fullPath"] }
            var placeId: BazarGraphQL.PlaceId { __data["placeId"] }
            var placeName: BazarGraphQL.PlaceName { __data["placeName"] }
            var roomId: BazarGraphQL.RoomId { __data["roomId"] }
            var roomName: BazarGraphQL.RoomName { __data["roomName"] }
          }
        }
      }
    }
  }

}