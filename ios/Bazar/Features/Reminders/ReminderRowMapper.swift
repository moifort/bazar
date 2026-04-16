import Foundation

enum ReminderRowMapper {
    static func map(_ reminder: Reminder) -> ReminderRow.Model {
        ReminderRow.Model(
            id: reminder.id,
            title: reminder.title,
            notes: reminder.notes,
            dueDate: reminder.dueDate,
            isRecurring: reminder.frequency != nil,
            frequencyLabel: reminder.frequency?.label,
            isOverdue: reminder.isOverdue
        )
    }
}
