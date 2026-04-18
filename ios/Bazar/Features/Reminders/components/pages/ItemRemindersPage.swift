import SwiftUI

struct ItemRemindersPage: View {
    let itemName: String
    let reminders: [ReminderRow.Model]
    let isLoading: Bool
    let errorMessage: String?

    let onRefresh: () async -> Void
    let onAdd: () -> Void
    let onEdit: (String) -> Void
    let onComplete: (String) async -> Void
    let onDelete: (String) async -> Void

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
                    ReminderRow(
                        title: reminder.title,
                        notes: reminder.notes,
                        dueDate: reminder.dueDate,
                        isRecurring: reminder.isRecurring,
                        frequencyLabel: reminder.frequencyLabel,
                        isOverdue: reminder.isOverdue,
                        showsOverdueBadge: true
                    )
                    .contentShape(.rect)
                    .onTapGesture { onEdit(reminder.id) }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await onDelete(reminder.id) }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                        Button {
                            Task { await onComplete(reminder.id) }
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
                    .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItemRemindersPage(
            itemName: "Cafetière",
            reminders: [
                .init(
                    id: "1",
                    title: "Détartrer",
                    notes: "",
                    dueDate: Date(timeIntervalSinceNow: 86_400 * 5),
                    isRecurring: true,
                    frequencyLabel: "Tous les 3 mois",
                    isOverdue: false
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
