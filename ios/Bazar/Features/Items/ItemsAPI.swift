import Apollo
import Foundation

enum GraphQLItemsAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func list(
        category: String? = nil,
        placeId: String? = nil,
        sort: String? = nil,
        order: String? = nil,
        offset: Int? = nil,
        limit: Int? = nil
    ) async throws -> ItemListPage {
        let query = BazarGraphQL.ItemListQuery(
            category: category.flatMap { BazarGraphQL.ItemCategory(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            placeId: GraphQLHelpers.graphQLNullable(placeId),
            roomId: .none,
            search: .none,
            sort: sort.flatMap { BazarGraphQL.ItemSort(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            order: order.flatMap { BazarGraphQL.SortOrder(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            offset: offset.map { .some($0) } ?? .none,
            limit: limit.map { .some($0) } ?? .none
        )
        let data = try await GraphQLHelpers.fetch(client, query: query)
        return ItemListPage(
            items: data.items.items.map { item in
                ItemListItem(
                    id: item.id,
                    name: item.name,
                    category: ItemCategory(rawValue: item.category.rawValue) ?? .other,
                    quantity: Int(item.quantity) ?? 1,
                    photoImageId: item.photoImageId,
                    locationFullPath: item.location?.fullPath,
                    addedBy: item.addedBy,
                    createdAt: GraphQLHelpers.parseISO8601(item.createdAt) ?? Date()
                )
            },
            totalCount: data.items.totalCount,
            hasMore: data.items.hasMore
        )
    }

    static func getDetail(id: String) async throws -> Item? {
        let query = BazarGraphQL.ItemDetailQuery(id: id)
        let data = try await GraphQLHelpers.fetch(client, query: query)
        guard let item = data.item else { return nil }
        return Item(
            id: item.id,
            name: item.name,
            description: item.description,
            category: ItemCategory(rawValue: item.category.rawValue) ?? .other,
            quantity: Int(item.quantity) ?? 1,
            photoImageId: item.photoImageId,
            addedBy: item.addedBy,
            personalNotes: item.personalNotes,
            createdAt: GraphQLHelpers.parseISO8601(item.createdAt) ?? Date(),
            updatedAt: GraphQLHelpers.parseISO8601(item.updatedAt) ?? Date(),
            location: item.location.map { loc in
                LocationPath(
                    fullPath: loc.fullPath,
                    placeId: loc.placeId,
                    placeName: loc.placeName,
                    roomId: loc.roomId,
                    roomName: loc.roomName,
                    zoneId: loc.zoneId,
                    zoneName: loc.zoneName,
                    storageId: loc.storageId,
                    storageName: loc.storageName
                )
            }
        )
    }

    static func add(input: BazarGraphQL.AddItemInput) async throws {
        let mutation = BazarGraphQL.AddItemMutation(input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func update(id: String, input: BazarGraphQL.UpdateItemInput) async throws {
        let mutation = BazarGraphQL.UpdateItemMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func delete(id: String) async throws {
        let mutation = BazarGraphQL.DeleteItemMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func move(id: String, storageId: String) async throws {
        let mutation = BazarGraphQL.MoveItemMutation(id: id, storageId: storageId)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func confirmItems(_ items: [BazarGraphQL.ConfirmItemInput]) async throws {
        let mutation = BazarGraphQL.ConfirmItemsMutation(input: items)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }
}
