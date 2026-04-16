import Foundation
import UserNotifications

enum NotificationManager {
    private static let identifierPrefix = "reminder-"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    static func scheduleReminder(_ reminder: Reminder, itemName: String) async {
        guard await requestAuthorizationIfNeeded() else { return }
        await cancelReminder(id: reminder.id)

        guard reminder.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "\(itemName)\(reminder.notes.isEmpty ? "" : " — \(reminder.notes)")"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: reminder.id),
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func cancelReminder(id: String) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier(for: id)])
    }

    /// Drops any pending notification whose identifier is not in `keep`.
    static func pruneNotifications(keepingIds keep: Set<String>) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let toRemove = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) && !keep.contains($0) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }
    }

    /// Reconcile the system schedule with the given reminders. Replaces the full set.
    static func syncAll(reminders: [Reminder], itemNames: [String: String]) async {
        let keep = Set(reminders.filter { $0.dueDate > Date() }.map { identifier(for: $0.id) })
        await pruneNotifications(keepingIds: keep)
        for reminder in reminders where reminder.dueDate > Date() {
            let itemName = itemNames[reminder.itemId] ?? ""
            await scheduleReminder(reminder, itemName: itemName)
        }
    }

    private static func identifier(for reminderId: String) -> String {
        "\(identifierPrefix)\(reminderId)"
    }
}
