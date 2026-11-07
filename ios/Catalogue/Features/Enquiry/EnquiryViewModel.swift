import Foundation

@MainActor
@Observable
final class EnquiryViewModel {
    let productId: Int
    let productTitle: String

    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var message: String = ""

    private(set) var isSubmitting = false
    private(set) var errorMessage: String?
    private(set) var thankYouReference: String?

    private let catalog: CatalogService

    init(productId: Int, productTitle: String, catalog: CatalogService) {
        self.productId = productId
        self.productTitle = productTitle
        self.catalog = catalog
    }

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && email.contains("@")
            && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isSubmitting
    }

    func submit() async {
        guard canSubmit else { return }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = EnquiryRequest(
            productId: productId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: trimmedPhone.isEmpty ? nil : trimmedPhone,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            let response = try await catalog.submitEnquiry(request)
            thankYouReference = response.reference
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
