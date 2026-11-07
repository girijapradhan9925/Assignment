import Foundation

enum AppConfig {
    /// Reads API_BASE_URL from Info.plist (injected via Config.xcconfig).
    static var apiBaseURL: URL {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: raw),
           !raw.isEmpty {
            return url
        }
        return URL(string: "http://localhost:3000")!
    }
}
