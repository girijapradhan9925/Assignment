import Foundation

protocol CatalogService: Sendable {
    func featuredProducts(limit: Int?) async throws -> [Product]
    func searchProducts(term: String) async throws -> [Product]
    func categories() async throws -> [Category]
    func categoryDetail(slug: String) async throws -> CategoryDetailResponse
    func product(id: Int) async throws -> Product
    func submitEnquiry(_ request: EnquiryRequest) async throws -> EnquiryResponse
}

final class RemoteCatalogService: CatalogService, @unchecked Sendable {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func featuredProducts(limit: Int? = nil) async throws -> [Product] {
        let response: FeaturedResponse = try await client.send(.featured(limit: limit))
        return response.items
    }

    func searchProducts(term: String) async throws -> [Product] {
        let response: ProductListResponse = try await client.send(.products(search: term))
        return response.items
    }

    func categories() async throws -> [Category] {
        let response: CategoriesResponse = try await client.send(.categories())
        return response.items
    }

    func categoryDetail(slug: String) async throws -> CategoryDetailResponse {
        try await client.send(.category(slug: slug))
    }

    func product(id: Int) async throws -> Product {
        try await client.send(.product(id: id))
    }

    func submitEnquiry(_ request: EnquiryRequest) async throws -> EnquiryResponse {
        try await client.send(.enquiry(request))
    }
}
