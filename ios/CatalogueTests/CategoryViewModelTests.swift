import Foundation
import Testing
@testable import Catalogue

@MainActor
struct CategoryViewModelTests {
    @Test func loadSplitsTopRatedAndOthers() async {
        let stub = StubCatalogService()
        let viewModel = CategoryViewModel(
            slug: "electronics",
            name: "electronics",
            catalog: stub
        )

        await viewModel.load()

        #expect(viewModel.topRated.isEmpty == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.name == "electronics")
    }

    @Test func loadSurfacesMissingCategory() async {
        let stub = StubCatalogService()
        let viewModel = CategoryViewModel(
            slug: "unknown",
            name: "Unknown",
            catalog: stub
        )

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.topRated.isEmpty)
    }
}
