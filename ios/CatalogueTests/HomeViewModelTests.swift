import Foundation
import Testing
@testable import Catalogue

@MainActor
struct HomeViewModelTests {
    @Test func loadPopulatesFeaturedAndCategories() async {
        let stub = StubCatalogService()
        let viewModel = HomeViewModel(catalog: stub)

        await viewModel.load()

        #expect(viewModel.featured.count == 5)
        #expect(viewModel.categories.count == 4)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func loadSurfacesErrors() async {
        let stub = StubCatalogService(
            shouldFailLoads: APIError.transport("offline")
        )
        let viewModel = HomeViewModel(catalog: stub)

        await viewModel.load()

        #expect(viewModel.featured.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
}
