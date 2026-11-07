import Foundation

@MainActor
@Observable
final class SearchViewModel {
    var query: String = ""
    private(set) var results: [Product] = []
    private(set) var hasSearched = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let catalog: CatalogService

    init(catalog: CatalogService) {
        self.catalog = catalog
    }

    func search() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            results = []
            hasSearched = false
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            results = try await catalog.searchProducts(term: term)
            hasSearched = true
        } catch {
            errorMessage = error.localizedDescription
            hasSearched = true
        }
    }
}
