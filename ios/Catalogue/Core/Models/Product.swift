import Foundation

struct ProductRating: Codable, Hashable, Sendable {
    let rate: Double
    let count: Int
}

struct Product: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let categorySlug: String
    let imageUrl: String
    let rating: ProductRating
}

struct Category: Codable, Identifiable, Hashable, Sendable {
    var id: String { slug }
    let slug: String
    let name: String
}

struct ProductListResponse: Codable, Sendable {
    let items: [Product]
    let total: Int
}

struct FeaturedResponse: Codable, Sendable {
    let items: [Product]
}

struct CategoriesResponse: Codable, Sendable {
    let items: [Category]
}

struct CategoryDetailResponse: Codable, Sendable {
    let category: Category
    let topRated: [Product]
    let others: [Product]
}

struct EnquiryRequest: Codable, Sendable {
    let productId: Int
    let name: String
    let email: String
    let phone: String?
    let message: String
}

struct EnquiryResponse: Codable, Sendable {
    let reference: String
}
