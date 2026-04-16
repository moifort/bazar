import SwiftUI

struct ItemRemindersView: View {
    let itemId: String
    let itemName: String
    var onChanged: () -> Void = {}

    @State private var reminders: [Reminder] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sheet: SheetTarget?

    var body: some View {
        ItemRemindersPage(
            itemName: itemName,
            reminders: reminders,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRefresh: { await load() },
            onAdd: { sheet = .new },
            onEdit: { sheet = .edit($0) },
            onComplete: { await complete($0) },
            onDelete: { await delete($0) }
        )
        .task { await load() }
        .sheet(item: $sheet) { target in
            NavigationStack {
                switch target {
                case .new:
                    ReminderEditSheet(
                        initial: .init(),
                        onSave: { fields in
                            try await add(fields)
                            sheet = nil
                        },
                        onCancel: { sheet = nil }
                    )
                    .navigationTitle("Nouveau rappel")
                    .navigationBarTitleDisplayMode(.inline)
                case .edit(let reminder):
                    ReminderEditSheet(
                        initial: .init(from: reminder),
                        onSave: { fields in
                            try await update(id: reminder.id, fields: fields)
                            sheet = nil
                        },
                        onCancel: { sheet = nil }
                    )
                    .navigationTitle("Modifier le rappel")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let item = try await GraphQLItemsAPI.getDetail(id: itemId)
            reminders = item?.reminders ?? []
        } catch {
            errorMessage = reportError(error)
        }
        isLoading = false
    }

    private func add(_ fields: ReminderEditSheet.Fields) async throws {
        let reminder = try await GraphQLRemindersAPI.add(
            itemId: itemId,
            title: fields.title,
            notes: fields.notes.isEmpty ? nil : fields.notes,
            dueDate: fields.dueDate,
            frequency: fields.frequency,
            customIntervalDays: fields.customIntervalDays
        )
        await NotificationManager.scheduleReminder(reminder, itemName: itemName)
        await load()
        onChanged()
    }

    private func update(id: String, fields: ReminderEditSheet.Fields) async throws {
        try await GraphQLRemindersAPI.update(
            id: id,
            title: fields.title,
            notes: fields.notes,
            dueDate: fields.dueDate,
            frequency: fields.frequency,
            customIntervalDays: fields.customIntervalDays
        )
        await NotificationManager.cancelReminder(id: id)
        let refreshed = Reminder(
            id: id,
            itemId: itemId,
            title: fields.title,
            notes: fields.notes,
            dueDate: fields.dueDate,
            frequency: fields.frequency,
            customIntervalDays: fields.customIntervalDays,
            createdAt: .now,
            updatedAt: .now
        )
        await NotificationManager.scheduleReminder(refreshed, itemName: itemName)
        await load()
        onChanged()
    }

    private func complete(_ reminder: Reminder) async {
        do {
            try await GraphQLRemindersAPI.complete(id: reminder.id)
            await NotificationManager.cancelReminder(id: reminder.id)
            await load()
            if let updated = reminders.first(where: { $0.id == reminder.id }) {
                await NotificationManager.scheduleReminder(updated, itemName: itemName)
            }
            onChanged()
        } catch {
            errorMessage = reportError(error)
        }
    }

    private func delete(_ reminder: Reminder) async {
        do {
            try await GraphQLRemindersAPI.delete(id: reminder.id)
            await NotificationManager.cancelReminder(id: reminder.id)
            await load()
            onChanged()
        } catch {
            errorMessage = reportError(error)
        }
    }

    private enum SheetTarget: Identifiable {
        case new
        case edit(Reminder)

        var id: String {
            switch self {
            case .new: "new"
            case .edit(let r): "edit-\(r.id)"
            }
        }
    }
}
