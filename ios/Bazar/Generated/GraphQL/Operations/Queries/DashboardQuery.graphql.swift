// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DashboardQuery: GraphQLQuery {
    static let operationName: String = "Dashboard"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Dashboard { dashboard { __typename totalItems itemsByCategory { __typename category count } itemsByPlace { __typename placeId placeName count } recentItems { __typename id name category quantity addedBy createdAt location { __typename fullPath } } lowStockItems { __typename id name category quantity lowStockThreshold location { __typename fullPath } } } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("dashboard", Dashboard.self),
      ] }

      /// Dashboard with inventory statistics
      var dashboard: Dashboard { __data["dashboard"] }

      /// Dashboard
      ///
      /// Parent Type: `Dashboard`
      struct Dashboard: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Dashboard }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalItems", Int.self),
          .field("itemsByCategory", [ItemsByCategory].self),
          .field("itemsByPlace", [ItemsByPlace].self),
          .field("recentItems", [RecentItem].self),
          .field("lowStockItems", [LowStockItem].self),
        ] }

        /// Total number of items
        var totalItems: Int { __data["totalItems"] }
        /// Item counts grouped by category
        var itemsByCategory: [ItemsByCategory] { __data["itemsByCategory"] }
        /// Item counts grouped by place
        var itemsByPlace: [ItemsByPlace] { __data["itemsByPlace"] }
        /// Most recently added items
        var recentItems: [RecentItem] { __data["recentItems"] }
        /// Items currently in low-stock state (quantity ≤ lowStockThreshold), sorted by name
        var lowStockItems: [LowStockItem] { __data["lowStockItems"] }

        /// Dashboard.ItemsByCategory
        ///
        /// Parent Type: `CategoryCount`
        struct ItemsByCategory: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.CategoryCount }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
            .field("count", Int.self),
          ] }

          /// Item category
          var category: GraphQLEnum<BazarGraphQL.ItemCategory> { __data["category"] }
          /// Number of items in this category
          var count: Int { __data["count"] }
        }

        /// Dashboard.ItemsByPlace
        ///
        /// Parent Type: `PlaceCount`
        struct ItemsByPlace: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.PlaceCount }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("placeId", String.self),
            .field("placeName", BazarGraphQL.PlaceName.self),
            .field("count", Int.self),
          ] }

          /// Place identifier
          var placeId: String { __data["placeId"] }
          /// Place display name
          var placeName: BazarGraphQL.PlaceName { __data["placeName"] }
          /// Number of items in this place
          var count: Int { __data["count"] }
        }

        /// Dashboard.RecentItem
        ///
        /// Parent Type: `Item`
        struct RecentItem: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BazarGraphQL.ItemId.self),
            .field("name", BazarGraphQL.ItemName.self),
            .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
            .field("quantity", BazarGraphQL.Quantity.self),
            .field("addedBy", BazarGraphQL.UserId.self),
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
          /// User who added this item
          var addedBy: BazarGraphQL.UserId { __data["addedBy"] }
          /// Creation date
          var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
          /// Resolved location path (storage or zone level)
          var location: Location? { __data["location"] }

          /// Dashboard.RecentItem.Location
          ///
          /// Parent Type: `LocationPath`
          struct Location: BazarGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.LocationPath }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("fullPath", String.self),
            ] }

            /// Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")
            var fullPath: String { __data["fullPath"] }
          }
        }

        /// Dashboard.LowStockItem
        ///
        /// Parent Type: `Item`
        struct LowStockItem: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BazarGraphQL.ItemId.self),
            .field("name", BazarGraphQL.ItemName.self),
            .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
            .field("quantity", BazarGraphQL.Quantity.self),
            .field("lowStockThreshold", Int?.self),
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
          /// Quantity threshold below which a low-stock notification fires
          var lowStockThreshold: Int? { __data["lowStockThreshold"] }
          /// Resolved location path (storage or zone level)
          var location: Location? { __data["location"] }

          /// Dashboard.LowStockItem.Location
          ///
          /// Parent Type: `LocationPath`
          struct Location: BazarGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.LocationPath }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("fullPath", String.self),
            ] }

            /// Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")
            var fullPath: String { __data["fullPath"] }
          }
        }
      }
    }
  }

}