import SwiftUI

struct ReminderRow: View {
    let title: String
    let notes: String
    let dueDate: Date
    let isRecurring: Bool
    let frequencyLabel: String?
    let isOverdue: Bool
    let showsOverdueBadge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                if isRecurring {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if showsOverdueBadge && isOverdue {
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
                Text(formatted(dueDate: dueDate))
                    .font(.caption)
                    .foregroundStyle(isOverdue ? .red : .secondary)
                if let frequencyLabel {
                    Text("· \(frequencyLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if !notes.isEmpty {
                Text(notes)
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

extension ReminderRow {
    struct Model: Identifiable, Sendable {
        let id: String
        let title: String
        let notes: String
        let dueDate: Date
        let isRecurring: Bool
        let frequencyLabel: String?
        let isOverdue: Bool
    }
}

#Preview {
    List {
        ReminderRow(
            title: "Détartrer",
            notes: "Utiliser le détartrant liquide",
            dueDate: Date(timeIntervalSinceNow: 86_400 * 3),
            isRecurring: true,
            frequencyLabel: "Tous les 3 mois",
            isOverdue: false,
            showsOverdueBadge: true
        )
        ReminderRow(
            title: "Changer la pile",
            notes: "",
            dueDate: Date(timeIntervalSinceNow: -86_400),
            isRecurring: false,
            frequencyLabel: nil,
            isOverdue: true,
            showsOverdueBadge: true
        )
    }
}
