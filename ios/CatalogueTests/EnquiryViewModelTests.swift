import Foundation
import Testing
@testable import Catalogue

@MainActor
struct EnquiryViewModelTests {
    @Test func submitSucceedsAndShowsThankYou() async {
        let stub = StubCatalogService(
            enquiryResult: .success(
                EnquiryResponse(reference: "ref-123")
            )
        )
        let viewModel = EnquiryViewModel(
            productId: 1,
            productTitle: "Backpack",
            catalog: stub
        )
        viewModel.name = "Ada Lovelace"
        viewModel.email = "ada@example.com"
        viewModel.message = "Interested in bulk pricing"

        await viewModel.submit()

        #expect(viewModel.thankYouReference == "ref-123")
        #expect(viewModel.errorMessage == nil)
        #expect(stub.lastEnquiry?.productId == 1)
        #expect(stub.lastEnquiry?.email == "ada@example.com")
        #expect(stub.lastEnquiry?.phone == nil)
    }

    @Test func submitIncludesOptionalPhone() async {
        let stub = StubCatalogService()
        let viewModel = EnquiryViewModel(
            productId: 1,
            productTitle: "Backpack",
            catalog: stub
        )
        viewModel.name = "Ada"
        viewModel.email = "ada@example.com"
        viewModel.phone = "+44 7700 900123"
        viewModel.message = "Hello"

        await viewModel.submit()

        #expect(stub.lastEnquiry?.phone == "+44 7700 900123")
    }

    @Test func submitSurfacesFailures() async {
        let stub = StubCatalogService(
            enquiryResult: .failure(
                APIError.http(statusCode: 502, message: "Email delivery failed")
            )
        )
        let viewModel = EnquiryViewModel(
            productId: 1,
            productTitle: "Backpack",
            catalog: stub
        )
        viewModel.name = "Ada"
        viewModel.email = "ada@example.com"
        viewModel.message = "Hello"

        await viewModel.submit()

        #expect(viewModel.thankYouReference == nil)
        #expect(viewModel.errorMessage == "Email delivery failed")
    }

    @Test func canSubmitRequiresNameEmailAndMessage() {
        let stub = StubCatalogService()
        let viewModel = EnquiryViewModel(
            productId: 1,
            productTitle: "Backpack",
            catalog: stub
        )

        #expect(viewModel.canSubmit == false)
        viewModel.name = "Ada"
        #expect(viewModel.canSubmit == false)
        viewModel.email = "ada@example.com"
        #expect(viewModel.canSubmit == false)
        viewModel.message = "Hello"
        #expect(viewModel.canSubmit == true)
    }
}
