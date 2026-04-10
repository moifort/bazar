// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating an existing item
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
      quantity: GraphQLNullable<Quantity> = nil
    ) {
      __data = InputDict([
        "category": category,
        "description": description,
        "name": name,
        "personalNotes": personalNotes,
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

    /// New quantity
    var quantity: GraphQLNullable<Quantity> {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }
  }

}