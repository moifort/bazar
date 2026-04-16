import Apollo
import Foundation

enum GraphQLRemindersAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func remindersDue(before: Date) async throws -> [Reminder] {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let query = BazarGraphQL.RemindersDueQuery(before: iso.string(from: before))
        let data = try await GraphQLHelpers.fetch(client, query: query)
        return data.remindersDue.map(mapReminder)
    }

    static func add(
        itemId: String,
        title: String,
        notes: String?,
        dueDate: Date,
        frequency: ReminderFrequency?,
        customIntervalDays: Int?
    ) async throws -> Reminder {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        nonisolated(unsafe) let input = BazarGraphQL.AddReminderInput(
            customIntervalDays: customIntervalDays.map { .some($0) } ?? .none,
            dueDate: iso.string(from: dueDate),
            frequency: frequency.flatMap {
                BazarGraphQL.ReminderFrequency(rawValue: $0.rawValue)
            }.map { .some(.case($0)) } ?? .none,
            itemId: itemId,
            notes: notes.map { .some($0) } ?? .none,
            title: title
        )
        let mutation = BazarGraphQL.AddReminderMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let reminder = data.addReminder
        return Reminder(
            id: reminder.id,
            itemId: reminder.itemId,
            title: reminder.title,
            notes: reminder.notes,
            dueDate: GraphQLHelpers.parseISO8601(reminder.dueDate) ?? Date(),
            frequency: reminder.frequency.flatMap { ReminderFrequency(rawValue: $0.rawValue) },
            customIntervalDays: reminder.customIntervalDays,
            createdAt: GraphQLHelpers.parseISO8601(reminder.createdAt) ?? Date(),
            updatedAt: GraphQLHelpers.parseISO8601(reminder.updatedAt) ?? Date()
        )
    }

    static func update(
        id: String,
        title: String,
        notes: String,
        dueDate: Date,
        frequency: ReminderFrequency?,
        customIntervalDays: Int?
    ) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        nonisolated(unsafe) let input = BazarGraphQL.UpdateReminderInput(
            customIntervalDays: customIntervalDays.map { .some($0) } ?? .null,
            dueDate: .some(iso.string(from: dueDate)),
            frequency: frequency.flatMap {
                BazarGraphQL.ReminderFrequency(rawValue: $0.rawValue)
            }.map { .some(.case($0)) } ?? .null,
            notes: .some(notes),
            title: .some(title)
        )
        let mutation = BazarGraphQL.UpdateReminderMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func complete(id: String) async throws {
        let mutation = BazarGraphQL.CompleteReminderMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func delete(id: String) async throws {
        let mutation = BazarGraphQL.DeleteReminderMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    private static func mapReminder(_ r: BazarGraphQL.RemindersDueQuery.Data.RemindersDue) -> Reminder {
        Reminder(
            id: r.id,
            itemId: r.itemId,
            title: r.title,
            notes: r.notes,
            dueDate: GraphQLHelpers.parseISO8601(r.dueDate) ?? Date(),
            frequency: r.frequency.flatMap { ReminderFrequency(rawValue: $0.rawValue) },
            customIntervalDays: r.customIntervalDays,
            createdAt: GraphQLHelpers.parseISO8601(r.createdAt) ?? Date(),
            updatedAt: GraphQLHelpers.parseISO8601(r.updatedAt) ?? Date()
        )
    }
}
