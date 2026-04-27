import SwiftUI

/// Sheet that lets the user edit every field of a scanned item before
/// confirmation. Reuses ItemEditForm so the scan flow and the item detail
/// flow share the exact same set of editable fields.
struct ScanItemDetailsSheet: View {
    let preview: EditablePreview
    let purchaseLocationSuggestions: [String]
    let onSave: (EditablePreview) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ItemEditForm(
                initial: ItemEditForm.Fields(
                    name: preview.name,
                    description: preview.description,
                    category: preview.category ?? .other,
                    quantity: preview.quantity,
                    notes: preview.personalNotes,
                    purchaseDate: preview.purchaseDate,
                    purchaseLocation: preview.purchaseLocation,
                    purchaseCondition: preview.purchaseCondition
                ),
                purchaseLocationSuggestions: purchaseLocationSuggestions,
                onSave: { fields in
                    var updated = preview
                    updated.name = fields.name
                    updated.description = fields.description
                    updated.category = fields.category
                    updated.quantity = fields.quantity
                    updated.personalNotes = fields.notes
                    updated.purchaseDate = fields.purchaseDate
                    updated.purchaseLocation = fields.purchaseLocation
                    updated.purchaseCondition = fields.purchaseCondition
                    onSave(updated)
                },
                onCancel: onCancel
            )
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
