import Foundation

/// Mutable working copy of an ItemPreview during the scan confirmation step.
struct EditablePreview: Identifiable, Equatable {
    let id: String
    var name: String
    var category: ItemCategory?
    var description: String
    var quantity: Int

    init(id: String, name: String, category: ItemCategory?, description: String, quantity: Int) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.quantity = quantity
    }

    init(from preview: ItemPreview) {
        self.init(
            id: preview.previewId,
            name: preview.name,
            category: preview.category,
            description: preview.description,
            quantity: preview.quantity
        )
    }

    func toPreview() -> ItemPreview {
        ItemPreview(
            previewId: id,
            name: name,
            category: category,
            description: description,
            quantity: quantity
        )
    }
}
