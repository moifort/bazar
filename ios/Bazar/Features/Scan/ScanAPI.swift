import Apollo

struct ConfirmItemInput: Sendable {
    let name: String
    let category: String
    let description: String?
    let quantity: Int
    let storageId: String?
    let previewImageBase64: String?
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
                quantity: preview.quantity
            )
        }
    }

    static func confirmItems(_ items: [ConfirmItemInput]) async throws {
        let graphQLInputs = items.map { item in
            BazarGraphQL.ConfirmItemInput(
                category: .case(BazarGraphQL.ItemCategory(rawValue: item.category) ?? .other),
                description: GraphQLHelpers.graphQLNullable(item.description),
                name: item.name,
                previewImageBase64: GraphQLHelpers.graphQLNullable(item.previewImageBase64),
                quantity: GraphQLHelpers.graphQLNullable(item.quantity > 1 ? "\(item.quantity)" : nil),
                storageId: GraphQLHelpers.graphQLNullable(item.storageId)
            )
        }
        try await GraphQLItemsAPI.confirmItems(graphQLInputs)
    }
}
