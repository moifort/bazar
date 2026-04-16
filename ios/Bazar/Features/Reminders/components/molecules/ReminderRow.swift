import SwiftUI

struct ReminderRow: View {
    let reminder: Reminder
    let showsOverdueBadge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(reminder.title)
                    .font(.headline)
                if reminder.frequency != nil {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if showsOverdueBadge && reminder.isOverdue {
                    Text("en retard")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.red.opacity(0.15), in: .capsule)
                }
            }
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatted(dueDate: reminder.dueDate))
                    .font(.caption)
                    .foregroundStyle(reminder.isOverdue ? .red : .secondary)
                if let freq = reminder.frequency {
                    Text("· \(freq.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if !reminder.notes.isEmpty {
                Text(reminder.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private func formatted(dueDate: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: dueDate, relativeTo: Date())
    }
}

#Preview {
    List {
        ReminderRow(
            reminder: Reminder(
                id: "1",
                itemId: "i1",
                title: "Détartrer",
                notes: "Utiliser le détartrant liquide",
                dueDate: Date(timeIntervalSinceNow: 86_400 * 3),
                frequency: .quarterly,
                customIntervalDays: nil,
                createdAt: .now,
                updatedAt: .now
            ),
            showsOverdueBadge: true
        )
        ReminderRow(
            reminder: Reminder(
                id: "2",
                itemId: "i1",
                title: "Changer la pile",
                notes: "",
                dueDate: Date(timeIntervalSinceNow: -86_400),
                frequency: nil,
                customIntervalDays: nil,
                createdAt: .now,
                updatedAt: .now
            ),
            showsOverdueBadge: true
        )
    }
}
