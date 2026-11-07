import Foundation
import Testing
@testable import Catalogue

@MainActor
struct SearchViewModelTests {
    @Test func searchFiltersByTerm() async {
        let stub = StubCatalogService()
        let viewModel = SearchViewModel(catalog: stub)
        viewModel.query = "ssd"

        await viewModel.search()

        #expect(viewModel.hasSearched)
        #expect(viewModel.results.map(\.id) == [6])
        #expect(stub.lastSearchTerm == "ssd")
    }

    @Test func emptyQueryDoesNotSearch() async {
        let stub = StubCatalogService()
        let viewModel = SearchViewModel(catalog: stub)
        viewModel.query = "   "

        await viewModel.search()

        #expect(viewModel.hasSearched == false)
        #expect(viewModel.results.isEmpty)
        #expect(stub.lastSearchTerm == nil)
    }

    @Test func searchSurfacesErrors() async {
        let stub = StubCatalogService(
            shouldFailLoads: APIError.http(statusCode: 502, message: "Upstream down")
        )
        let viewModel = SearchViewModel(catalog: stub)
        viewModel.query = "bag"

        await viewModel.search()

        #expect(viewModel.hasSearched)
        #expect(viewModel.errorMessage == "Upstream down")
    }
}
