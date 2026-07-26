import Apollo
import Foundation

struct ConfirmItemInput: Sendable {
    let name: String
    let category: String
    let description: String?
    let tags: [String]
    let quantity: Int
    let storageId: String?
    let zoneId: String?
    let personalNotes: String?
    let purchaseDate: Date?
    let purchaseLocation: String?
    let purchaseCondition: PurchaseCondition?
}

enum GraphQLScanAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func analyze(imageBase64: String) async throws -> [ItemPreview] {
        let mutation = BazarGraphQL.AnalyzeItemPhotoMutation(imageBase64: imageBase64)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        return data.analyzeItemPhoto.map { preview in
            ItemPreview(
                previewId: preview.previewId,
                name: preview.name,
                category: preview.category.flatMap { ItemCategory(rawValue: $0) },
                description: preview.description,
                quantity: preview.quantity,
                tags: preview.tags
            )
        }
    }

    static func confirmItems(_ items: [ConfirmItemInput]) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let graphQLInputs = items.map { item in
            BazarGraphQL.ConfirmItemInput(
                category: .case(BazarGraphQL.ItemCategory(rawValue: item.category) ?? .other),
                description: GraphQLHelpers.graphQLNullable(item.description),
                name: item.name,
                personalNotes: GraphQLHelpers.graphQLNullable(item.personalNotes?.isEmpty == false ? item.personalNotes : nil),
                purchaseCondition: graphQLPurchaseCondition(item.purchaseCondition),
                purchaseDate: GraphQLHelpers.graphQLNullable(item.purchaseDate.map { iso.string(from: $0) }),
                purchaseLocation: GraphQLHelpers.graphQLNullable(item.purchaseLocation?.isEmpty == false ? item.purchaseLocation : nil),
                quantity: GraphQLHelpers.graphQLNullable(item.quantity > 1 ? "\(item.quantity)" : nil),
                storageId: GraphQLHelpers.graphQLNullable(item.storageId),
                tags: .some(item.tags),
                zoneId: GraphQLHelpers.graphQLNullable(item.zoneId)
            )
        }
        try await GraphQLItemsAPI.confirmItems(graphQLInputs)
    }

    private static func graphQLPurchaseCondition(
        _ condition: PurchaseCondition?
    ) -> GraphQLNullable<GraphQLEnum<BazarGraphQL.PurchaseCondition>> {
        guard let condition,
              let value = BazarGraphQL.PurchaseCondition(rawValue: condition.rawValue)
        else {
            return .null
        }
        return .some(.case(value))
    }
}
