import Apollo
import Foundation

/// Registers and unregisters the device's FCM token with the backend.
actor NotificationSubscriber {
    static let shared = NotificationSubscriber()

    private var lastSentToken: String?

    func subscribe(token: String) async {
        guard token != lastSentToken else { return }
        let mutation = BazarGraphQL.SubscribeToNotificationsMutation(token: token)
        do {
            _ = try await GraphQLHelpers.perform(GraphQLClient.shared.apollo, mutation: mutation)
            lastSentToken = token
        } catch {
            print("[push] subscribeToNotifications failed: \(error.localizedDescription)")
        }
    }

    func unsubscribe(token: String) async {
        let mutation = BazarGraphQL.UnsubscribeFromNotificationsMutation(token: token)
        _ = try? await GraphQLHelpers.perform(GraphQLClient.shared.apollo, mutation: mutation)
        if lastSentToken == token { lastSentToken = nil }
    }
}
