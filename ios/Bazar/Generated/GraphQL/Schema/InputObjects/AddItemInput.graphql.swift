// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for manually adding a new item
  struct AddItemInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      category: GraphQLEnum<ItemCategory>,
      description: GraphQLNullable<String> = nil,
      invoiceImageBase64: GraphQLNullable<String> = nil,
      name: ItemName,
      personalNotes: GraphQLNullable<String> = nil,
      photoBase64: GraphQLNullable<String> = nil,
      purchaseDate: GraphQLNullable<DateTime> = nil,
      purchaseLocation: GraphQLNullable<String> = nil,
      quantity: GraphQLNullable<Quantity> = nil,
      storageId: GraphQLNullable<StorageId> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "invoiceImageBase64": invoiceImageBase64,
        "name": name,
        "personalNotes": personalNotes,
        "photoBase64": photoBase64,
        "purchaseDate": purchaseDate,
        "purchaseLocation": purchaseLocation,
        "quantity": quantity,
        "storageId": storageId
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

    /// Invoice photo as base64 encoded string
    var invoiceImageBase64: GraphQLNullable<String> {
      get { __data["invoiceImageBase64"] }
      set { __data["invoiceImageBase64"] = newValue }
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

    /// Photo as base64 encoded string
    var photoBase64: GraphQLNullable<String> {
      get { __data["photoBase64"] }
      set { __data["photoBase64"] = newValue }
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

    /// Storage location
    var storageId: GraphQLNullable<StorageId> {
      get { __data["storageId"] }
      set { __data["storageId"] = newValue }
    }
  }

}