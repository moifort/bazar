import Foundation

struct ConfirmItemInput: Sendable {
    let name: String
    let category: String
    let description: String?
    let quantity: Int
    let storageId: String?
    let previewImageBase64: String?
}

enum ScanAPI {
    static func analyze(imageBase64: String) async throws -> [ItemPreview] {
        []
    }

    static func confirmItems(_ items: [ConfirmItemInput]) async throws -> [ItemListItem] {
        []
    }
}
