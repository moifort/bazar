// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for confirming a scanned item
  struct ConfirmItemInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      category: GraphQLEnum<ItemCategory>,
      description: GraphQLNullable<String> = nil,
      lowStockThreshold: GraphQLNullable<Int> = nil,
      name: ItemName,
      personalNotes: GraphQLNullable<String> = nil,
      purchaseCondition: GraphQLNullable<GraphQLEnum<PurchaseCondition>> = nil,
      purchaseDate: GraphQLNullable<DateTime> = nil,
      purchaseLocation: GraphQLNullable<String> = nil,
      quantity: GraphQLNullable<Quantity> = nil,
      storageId: GraphQLNullable<StorageId> = nil,
      zoneId: GraphQLNullable<ZoneId> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "lowStockThreshold": lowStockThreshold,
        "name": name,
        "personalNotes": personalNotes,
        "purchaseCondition": purchaseCondition,
        "purchaseDate": purchaseDate,
        "purchaseLocation": purchaseLocation,
        "quantity": quantity,
        "storageId": storageId,
        "zoneId": zoneId
      ])
    }

    /// Item category
    var category: GraphQLEnum<ItemCategory> {
      get { __data["category"] }
      set { __data["category"] = newValue }
    }

    /// Item description
    var description: GraphQLNullable<String> {
      get { __data["description"] }
      set { __data["description"] = newValue }
    }

    /// Quantity threshold below which a low-stock notification fires (positive integer)
    var lowStockThreshold: GraphQLNullable<Int> {
      get { __data["lowStockThreshold"] }
      set { __data["lowStockThreshold"] = newValue }
    }

    /// Item name
    var name: ItemName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Personal notes
    var personalNotes: GraphQLNullable<String> {
      get { __data["personalNotes"] }
      set { __data["personalNotes"] = newValue }
    }

    /// Whether the item was bought new or used
    var purchaseCondition: GraphQLNullable<GraphQLEnum<PurchaseCondition>> {
      get { __data["purchaseCondition"] }
      set { __data["purchaseCondition"] = newValue }
    }

    /// Date the item was purchased
    var purchaseDate: GraphQLNullable<DateTime> {
      get { __data["purchaseDate"] }
      set { __data["purchaseDate"] = newValue }
    }

    /// Where the item was purchased
    var purchaseLocation: GraphQLNullable<String> {
      get { __data["purchaseLocation"] }
      set { __data["purchaseLocation"] = newValue }
    }

    /// Quantity (default 1)
    var quantity: GraphQLNullable<Quantity> {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }

    /// Storage attachment (mutually exclusive with zoneId)
    var storageId: GraphQLNullable<StorageId> {
      get { __data["storageId"] }
      set { __data["storageId"] = newValue }
    }

    /// Zone attachment when no storage is chosen
    var zoneId: GraphQLNullable<ZoneId> {
      get { __data["zoneId"] }
      set { __data["zoneId"] = newValue }
    }
  }

}