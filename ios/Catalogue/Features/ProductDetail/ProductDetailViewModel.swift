import Foundation

@MainActor
@Observable
final class ProductDetailViewModel {
    let productId: Int
    private(set) var product: Product?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let catalog: CatalogService

    init(productId: Int, catalog: CatalogService) {
        self.productId = productId
        self.catalog = catalog
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            product = try await catalog.product(id: productId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
