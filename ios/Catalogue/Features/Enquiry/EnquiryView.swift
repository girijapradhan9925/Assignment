import SwiftUI

struct EnquiryView: View {
    @State private var viewModel: EnquiryViewModel

    init(productId: Int, productTitle: String, catalog: CatalogService) {
        _viewModel = State(
            initialValue: EnquiryViewModel(
                productId: productId,
                productTitle: productTitle,
                catalog: catalog
            )
        )
    }

    var body: some View {
        Group {
            if let reference = viewModel.thankYouReference {
                thankYou(reference: reference)
            } else {
                form
            }
        }
        .navigationTitle("Enquire")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var form: some View {
        Form {
            Section {
                Text(viewModel.productTitle)
                    .font(Theme.Typography.headline)
            } header: {
                Text("Product")
            }

            Section {
                TextField("Full name", text: $viewModel.name)
                    .textContentType(.name)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Phone (optional)", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            } header: {
                Text("Your details")
            }

            Section {
                TextField("How can we help?", text: $viewModel.message, axis: .vertical)
                    .lineLimit(4...8)
            } header: {
                Text("Message")
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(Theme.Color.danger)
                        .font(Theme.Typography.caption)
                }
            }

            Section {
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit enquiry")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
    }

    private func thankYou(reference: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Color.success)
            Text("Thank you")
                .font(Theme.Typography.title)
            Text("We've received your enquiry about \(viewModel.productTitle). Our sales team will be in touch.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.secondaryText)
                .multilineTextAlignment(.center)
            Text("Reference: \(reference)")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Color.secondaryText)
                .textSelection(.enabled)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
