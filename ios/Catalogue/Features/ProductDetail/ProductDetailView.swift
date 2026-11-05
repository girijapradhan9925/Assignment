import SwiftUI

struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel
    private let catalog: CatalogService

    init(productId: Int, catalog: CatalogService) {
        self.catalog = catalog
        _viewModel = State(
            initialValue: ProductDetailViewModel(productId: productId, catalog: catalog)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.product == nil {
                LoadingView()
            } else if let error = viewModel.errorMessage, viewModel.product == nil {
                ErrorStateView(message: error) {
                    Task { await viewModel.load() }
                }
            } else if let product = viewModel.product {
                detail(product)
            }
        }
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func detail(_ product: Product) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                RemoteImage(urlString: product.imageUrl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(Theme.Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))

                Text(product.title)
                    .font(Theme.Typography.title)

                HStack {
                    Text(product.price, format: .currency(code: "USD"))
                        .font(Theme.Typography.price)
                        .foregroundStyle(Theme.Color.accent)
                    Spacer()
                    Label(
                        "\(String(format: "%.1f", product.rating.rate)) (\(product.rating.count))",
                        systemImage: "star.fill"
                    )
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Color.secondaryText)
                }

                Text(product.category.capitalized)
                    .font(Theme.Typography.caption)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xxs)
                    .background(Theme.Color.secondaryBackground)
                    .clipShape(Capsule())

                Text(product.description)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Color.primaryText)

                NavigationLink(value: AppRoute.enquiry(productId: product.id, productTitle: product.title)) {
                    Text("Enquire")
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.sm)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(Theme.Spacing.md)
        }
    }
}
