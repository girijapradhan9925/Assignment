import Foundation

/// In-memory catalogue used by previews and unit tests.
final class StubCatalogService: CatalogService, @unchecked Sendable {
    var featured: [Product]
    var allProducts: [Product]
    var categoriesList: [Category]
    var categoryDetails: [String: CategoryDetailResponse]
    var enquiryResult: Result<EnquiryResponse, Error>
    var shouldFailLoads: Error?

    private(set) var lastEnquiry: EnquiryRequest?
    private(set) var lastSearchTerm: String?

    init(
        featured: [Product] = StubCatalogService.sampleProducts.prefix(5).map { $0 },
        allProducts: [Product] = StubCatalogService.sampleProducts,
        categoriesList: [Category] = StubCatalogService.sampleCategories,
        categoryDetails: [String: CategoryDetailResponse] = StubCatalogService.sampleCategoryDetails,
        enquiryResult: Result<EnquiryResponse, Error> = .success(
            EnquiryResponse(reference: "00000000-0000-4000-8000-000000000001")
        ),
        shouldFailLoads: Error? = nil
    ) {
        self.featured = featured
        self.allProducts = allProducts
        self.categoriesList = categoriesList
        self.categoryDetails = categoryDetails
        self.enquiryResult = enquiryResult
        self.shouldFailLoads = shouldFailLoads
    }

    func featuredProducts(limit: Int?) async throws -> [Product] {
        try throwIfNeeded()
        let capped = limit.map { Array(featured.prefix($0)) } ?? featured
        return capped
    }

    func searchProducts(term: String) async throws -> [Product] {
        try throwIfNeeded()
        lastSearchTerm = term
        let needle = term.lowercased()
        return allProducts.filter {
            $0.title.lowercased().contains(needle)
                || $0.description.lowercased().contains(needle)
                || $0.category.lowercased().contains(needle)
        }
    }

    func categories() async throws -> [Category] {
        try throwIfNeeded()
        return categoriesList
    }

    func categoryDetail(slug: String) async throws -> CategoryDetailResponse {
        try throwIfNeeded()
        guard let detail = categoryDetails[slug] else {
            throw APIError.http(statusCode: 404, message: "Category '\(slug)' not found")
        }
        return detail
    }

    func product(id: Int) async throws -> Product {
        try throwIfNeeded()
        guard let product = allProducts.first(where: { $0.id == id }) else {
            throw APIError.http(statusCode: 404, message: "Product \(id) not found")
        }
        return product
    }

    func submitEnquiry(_ request: EnquiryRequest) async throws -> EnquiryResponse {
        lastEnquiry = request
        switch enquiryResult {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }

    private func throwIfNeeded() throws {
        if let shouldFailLoads {
            throw shouldFailLoads
        }
    }
}

extension StubCatalogService {
    static let sampleProducts: [Product] = [
        Product(
            id: 1,
            title: "Fjallraven Backpack",
            price: 109.95,
            description: "Your perfect pack for everyday use.",
            category: "men's clothing",
            categorySlug: "mens-clothing",
            imageUrl: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png",
            rating: ProductRating(rate: 3.9, count: 120)
        ),
        Product(
            id: 2,
            title: "Mens Casual T-Shirt",
            price: 22.3,
            description: "Slim-fitting style.",
            category: "men's clothing",
            categorySlug: "mens-clothing",
            imageUrl: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png",
            rating: ProductRating(rate: 4.1, count: 259)
        ),
        Product(
            id: 3,
            title: "Gold Petite Micropave",
            price: 168,
            description: "Satisfaction Guaranteed.",
            category: "jewelery",
            categorySlug: "jewelery",
            imageUrl: "https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_t.png",
            rating: ProductRating(rate: 4.6, count: 400)
        ),
        Product(
            id: 5,
            title: "WD 2TB Hard Drive",
            price: 64,
            description: "USB 3.0 portable storage.",
            category: "electronics",
            categorySlug: "electronics",
            imageUrl: "https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_t.png",
            rating: ProductRating(rate: 4.8, count: 203)
        ),
        Product(
            id: 6,
            title: "SanDisk SSD PLUS 1TB",
            price: 109,
            description: "Easy upgrade for faster boot.",
            category: "electronics",
            categorySlug: "electronics",
            imageUrl: "https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_t.png",
            rating: ProductRating(rate: 4.8, count: 500)
        ),
        Product(
            id: 8,
            title: "MBJ Women's Short Sleeve",
            price: 9.85,
            description: "95% RAYON 5% SPANDEX.",
            category: "women's clothing",
            categorySlug: "womens-clothing",
            imageUrl: "https://fakestoreapi.com/img/71z3kpMAYsL._AC_UY879_t.png",
            rating: ProductRating(rate: 4.7, count: 130)
        ),
    ]

    static let sampleCategories: [Category] = [
        Category(slug: "electronics", name: "electronics"),
        Category(slug: "jewelery", name: "jewelery"),
        Category(slug: "mens-clothing", name: "men's clothing"),
        Category(slug: "womens-clothing", name: "women's clothing"),
    ]

    static var sampleCategoryDetails: [String: CategoryDetailResponse] {
        Dictionary(uniqueKeysWithValues: sampleCategories.map { category in
            let products = sampleProducts.filter { $0.categorySlug == category.slug }
            let top = Array(products.prefix(3))
            let others = Array(products.dropFirst(3))
            return (
                category.slug,
                CategoryDetailResponse(category: category, topRated: top, others: others)
            )
        })
    }
}
