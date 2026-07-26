import Foundation

/// Mutable working copy of an ItemPreview during the scan confirmation step.
struct EditablePreview: Identifiable, Equatable {
    let id: String
    var name: String
    var category: ItemCategory?
    var description: String
    var tags: [String]
    var quantity: Int
    var personalNotes: String
    var purchaseDate: Date?
    var purchaseLocation: String
    var purchaseCondition: PurchaseCondition?

    init(
        id: String,
        name: String,
        category: ItemCategory?,
        description: String,
        quantity: Int,
        tags: [String] = [],
        personalNotes: String = "",
        purchaseDate: Date? = nil,
        purchaseLocation: String = "",
        purchaseCondition: PurchaseCondition? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.tags = tags
        self.quantity = quantity
        self.personalNotes = personalNotes
        self.purchaseDate = purchaseDate
        self.purchaseLocation = purchaseLocation
        self.purchaseCondition = purchaseCondition
    }

    init(from preview: ItemPreview) {
        self.init(
            id: preview.previewId,
            name: preview.name,
            category: preview.category,
            description: preview.description,
            quantity: preview.quantity,
            tags: preview.tags,
            personalNotes: preview.personalNotes,
            purchaseDate: preview.purchaseDate,
            purchaseLocation: preview.purchaseLocation,
            purchaseCondition: preview.purchaseCondition
        )
    }

    func toPreview() -> ItemPreview {
        ItemPreview(
            previewId: id,
            name: name,
            category: category,
            description: description,
            quantity: quantity,
            tags: tags,
            personalNotes: personalNotes,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            purchaseCondition: purchaseCondition
        )
    }
}
