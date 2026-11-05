import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var featured: [Product] = []
    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let catalog: CatalogService

    init(catalog: CatalogService) {
        self.catalog = catalog
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let featuredTask = catalog.featuredProducts(limit: 5)
            async let categoriesTask = catalog.categories()
            featured = try await featuredTask
            categories = try await categoriesTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
