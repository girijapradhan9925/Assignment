import Foundation

@MainActor
@Observable
final class CategoryViewModel {
    let slug: String
    private(set) var name: String
    private(set) var topRated: [Product] = []
    private(set) var others: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let catalog: CatalogService

    init(slug: String, name: String, catalog: CatalogService) {
        self.slug = slug
        self.name = name
        self.catalog = catalog
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let detail = try await catalog.categoryDetail(slug: slug)
            name = detail.category.name
            topRated = detail.topRated
            others = detail.others
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
