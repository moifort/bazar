import SwiftUI

struct ItemRemindersPage: View {
    let itemName: String
    let reminders: [Reminder]
    let isLoading: Bool
    let errorMessage: String?

    let onRefresh: () async -> Void
    let onAdd: () -> Void
    let onEdit: (Reminder) -> Void
    let onComplete: (Reminder) async -> Void
    let onDelete: (Reminder) async -> Void

    var body: some View {
        List {
            if reminders.isEmpty && !isLoading {
                ContentUnavailableView(
                    "Aucun rappel",
                    systemImage: "bell.slash",
                    description: Text("Ajoutez un rappel pour ne rien oublier")
                )
            } else {
                ForEach(reminders) { reminder in
                    ReminderRow(reminder: reminder, showsOverdueBadge: true)
                        .contentShape(.rect)
                        .onTapGesture { onEdit(reminder) }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await onDelete(reminder) }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                            Button {
                                Task { await onComplete(reminder) }
                            } label: {
                                Label("Fait", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                }
            }
        }
        .navigationTitle("Rappels — \(itemName)")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await onRefresh() }
        .overlay {
            if isLoading && reminders.isEmpty {
                ProgressView()
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { errorMessage != nil },
            set: { _ in }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Ajouter", systemImage: "plus") { onAdd() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItemRemindersPage(
            itemName: "Cafetière",
            reminders: [
                Reminder(
                    id: "1",
                    itemId: "i1",
                    title: "Détartrer",
                    notes: "",
                    dueDate: Date(timeIntervalSinceNow: 86_400 * 5),
                    frequency: .quarterly,
                    customIntervalDays: nil,
                    createdAt: .now,
                    updatedAt: .now
                )
            ],
            isLoading: false,
            errorMessage: nil,
            onRefresh: {},
            onAdd: {},
            onEdit: { _ in },
            onComplete: { _ in },
            onDelete: { _ in }
        )
    }
}
