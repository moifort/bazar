import Foundation

enum SharedConfig {
    enum Environment: String {
        case dev
        case production
    }

    static let environmentKey = "environment"
    static let devServerURLKey = "devServerURL"
    static let productionURLKey = "productionURL"
    static let userTagKey = "userTag"

    static let defaultDevURL = "http://192.168.1.206:3000"
    static let productionURL = "https://bazar.mottet.me"
    static let defaultEnvironment: Environment = .dev
    static let defaultUserTag = "thibaut"

    static var environment: Environment {
        let raw = UserDefaults.standard.string(forKey: environmentKey) ?? ""
        return Environment(rawValue: raw) ?? defaultEnvironment
    }

    static var devServerURL: String {
        let value = UserDefaults.standard.string(forKey: devServerURLKey)
        return (value?.isEmpty ?? true) ? defaultDevURL : value!
    }

    static var serverURL: String {
        switch environment {
        case .production: return productionURL
        case .dev: return devServerURL
        }
    }

    static var userTag: String {
        let value = UserDefaults.standard.string(forKey: userTagKey)
        return (value?.isEmpty ?? true) ? defaultUserTag : value!
    }
}
