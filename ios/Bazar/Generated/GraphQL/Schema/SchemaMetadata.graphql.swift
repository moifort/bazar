// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol BazarGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == BazarGraphQL.SchemaMetadata {}

protocol BazarGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == BazarGraphQL.SchemaMetadata {}

protocol BazarGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == BazarGraphQL.SchemaMetadata {}

protocol BazarGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == BazarGraphQL.SchemaMetadata {}

extension BazarGraphQL {
  typealias SelectionSet = BazarGraphQL_SelectionSet

  typealias InlineFragment = BazarGraphQL_InlineFragment

  typealias MutableSelectionSet = BazarGraphQL_MutableSelectionSet

  typealias MutableInlineFragment = BazarGraphQL_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "CategoryCount": return BazarGraphQL.Objects.CategoryCount
      case "Dashboard": return BazarGraphQL.Objects.Dashboard
      case "Item": return BazarGraphQL.Objects.Item
      case "ItemPreview": return BazarGraphQL.Objects.ItemPreview
      case "Items": return BazarGraphQL.Objects.Items
      case "LocationPath": return BazarGraphQL.Objects.LocationPath
      case "Mutation": return BazarGraphQL.Objects.Mutation
      case "Place": return BazarGraphQL.Objects.Place
      case "PlaceCount": return BazarGraphQL.Objects.PlaceCount
      case "Query": return BazarGraphQL.Objects.Query
      case "Reminder": return BazarGraphQL.Objects.Reminder
      case "Room": return BazarGraphQL.Objects.Room
      case "SearchEntry": return BazarGraphQL.Objects.SearchEntry
      case "Storage": return BazarGraphQL.Objects.Storage
      case "Zone": return BazarGraphQL.Objects.Zone
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}