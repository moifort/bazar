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
      name: ItemName,
      previewImageBase64: GraphQLNullable<String> = nil,
      quantity: GraphQLNullable<Quantity> = nil,
      storageId: GraphQLNullable<StorageId> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "name": name,
        "previewImageBase64": previewImageBase64,
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

    /// Item name
    var name: ItemName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Photo from scan preview as base64
    var previewImageBase64: GraphQLNullable<String> {
      get { __data["previewImageBase64"] }
      set { __data["previewImageBase64"] = newValue }
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