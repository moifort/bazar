// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating an existing item. Absent fields preserve the current value; for invoiceImageBase64 pass an empty string to clear the existing invoice.
  struct UpdateItemInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      category: GraphQLNullable<GraphQLEnum<ItemCategory>> = nil,
      description: GraphQLNullable<String> = nil,
      invoiceImageBase64: GraphQLNullable<String> = nil,
      name: GraphQLNullable<ItemName> = nil,
      personalNotes: GraphQLNullable<String> = nil,
      purchaseDate: GraphQLNullable<DateTime> = nil,
      purchaseLocation: GraphQLNullable<String> = nil,
      quantity: GraphQLNullable<Quantity> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "invoiceImageBase64": invoiceImageBase64,
        "name": name,
        "personalNotes": personalNotes,
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

    /// Invoice photo as base64. Non-empty replaces the existing invoice; empty string clears it.
    var invoiceImageBase64: GraphQLNullable<String> {
      get { __data["invoiceImageBase64"] }
      set { __data["invoiceImageBase64"] = newValue }
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