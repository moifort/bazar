import Foundation

@MainActor @Observable
final class DashboardViewModel {
    var data: DashboardData?
    var isLoading = false
    var error: String?

    func load() async {
        isLoading = true
        error = nil
        do {
            data = try await GraphQLDashboardAPI.getData()
        } catch is CancellationError {
            // Ignored — task cancelled by SwiftUI (e.g. refreshTrigger changed)
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }
}
