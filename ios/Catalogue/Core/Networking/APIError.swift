import Foundation

enum APIError: Error, LocalizedError, Sendable, Equatable {
    case invalidURL
    case invalidResponse
    case http(statusCode: Int, message: String?)
    case decoding(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case let .http(_, message):
            return message ?? "The request failed."
        case let .decoding(detail):
            return "Could not read the server response. (\(detail))"
        case let .transport(detail):
            return "Network error: \(detail)"
        }
    }
}

struct APIErrorBody: Codable, Sendable {
    struct Detail: Codable, Sendable {
        let code: String
        let message: String
    }

    let error: Detail
}
