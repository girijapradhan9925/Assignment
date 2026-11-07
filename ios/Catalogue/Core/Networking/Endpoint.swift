import Foundation

struct Endpoint: Sendable {
    let path: String
    var method: String = "GET"
    var queryItems: [URLQueryItem] = []
    var body: Data? = nil

    static func featured(limit: Int? = nil) -> Endpoint {
        var items: [URLQueryItem] = []
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return Endpoint(path: "/api/products/featured", queryItems: items)
    }

    static func products(search: String? = nil, category: String? = nil) -> Endpoint {
        var items: [URLQueryItem] = []
        if let search, !search.isEmpty {
            items.append(URLQueryItem(name: "search", value: search))
        }
        if let category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        return Endpoint(path: "/api/products", queryItems: items)
    }

    static func product(id: Int) -> Endpoint {
        Endpoint(path: "/api/products/\(id)")
    }

    static func categories() -> Endpoint {
        Endpoint(path: "/api/categories")
    }

    static func category(slug: String) -> Endpoint {
        Endpoint(path: "/api/categories/\(slug)")
    }

    static func enquiry(_ request: EnquiryRequest) throws -> Endpoint {
        let data = try JSONEncoder().encode(request)
        return Endpoint(
            path: "/api/enquiries",
            method: "POST",
            body: data
        )
    }
}
