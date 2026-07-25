import Foundation

enum SharedConfig {
    /// Override the production URL via UserDefaults["serverURL"] for local dev
    /// (e.g. when pointing the app at the Firebase emulator). Defaults to the
    /// deployed Cloud Function URL.
    static let serverURLKey = "serverURL"
    static let defaultServerURL = "https://bazar-server-jk67e74biq-ey.a.run.app"

    static var serverURL: URL {
        let stored = UserDefaults.standard.string(forKey: serverURLKey)
            ?? defaultServerURL
        return URL(string: stored) ?? URL(string: defaultServerURL)!
    }

    /// A Sentry DSN is public by design, so it lives here with the rest of the
    /// committed configuration rather than in the gitignored Secrets.swift —
    /// which release builds on CI would never see. A blank or non-URL value
    /// leaves error reporting disabled, mirroring the backend plugin
    /// (server/plugins/01-sentry.ts).
    static let sentryDSN =
        "https://21c2033261877d3149930f99fe79d90f@o4510952263909376.ingest.de.sentry.io/4511795317243984"
}
