// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating an existing item. Absent fields preserve the current value.
  struct UpdateItemInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      category: GraphQLNullable<GraphQLEnum<ItemCategory>> = nil,
      description: GraphQLNullable<String> = nil,
      name: GraphQLNullable<ItemName> = nil,
      personalNotes: GraphQLNullable<String> = nil,
      purchaseCondition: GraphQLNullable<GraphQLEnum<PurchaseCondition>> = nil,
      purchaseDate: GraphQLNullable<DateTime> = nil,
      purchaseLocation: GraphQLNullable<String> = nil,
      quantity: GraphQLNullable<Quantity> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "name": name,
        "personalNotes": personalNotes,
        "purchaseCondition": purchaseCondition,
        "purchaseDate": purchaseDate,
        "purchaseLocation": purchaseLocation,
        "quantity": quantity
      ])
    }

    /// New category
    var category: GraphQLNullable<GraphQLEnum<ItemCategory>> {
      get { __data["category"] }
      set { __data["category"] = newValue }
    }

    /// New description
    var description: GraphQLNullable<String> {
      get { __data["description"] }
      set { __data["description"] = newValue }
    }

    /// New item name
    var name: GraphQLNullable<ItemName> {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// New personal notes
    var personalNotes: GraphQLNullable<String> {
      get { __data["personalNotes"] }
      set { __data["personalNotes"] = newValue }
    }

    /// New purchase condition (omit to leave unchanged)
    var purchaseCondition: GraphQLNullable<GraphQLEnum<PurchaseCondition>> {
      get { __data["purchaseCondition"] }
      set { __data["purchaseCondition"] = newValue }
    }

    /// New purchase date (null to clear)
    var purchaseDate: GraphQLNullable<DateTime> {
      get { __data["purchaseDate"] }
      set { __data["purchaseDate"] = newValue }
    }

    /// New purchase location (empty string to clear)
    var purchaseLocation: GraphQLNullable<String> {
      get { __data["purchaseLocation"] }
      set { __data["purchaseLocation"] = newValue }
    }

    /// New quantity
    var quantity: GraphQLNullable<Quantity> {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }
  }

}