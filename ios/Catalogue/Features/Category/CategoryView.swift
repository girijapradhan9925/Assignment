import SwiftUI

struct CategoryView: View {
    @State private var viewModel: CategoryViewModel

    init(slug: String, name: String, catalog: CatalogService) {
        _viewModel = State(
            initialValue: CategoryViewModel(slug: slug, name: name, catalog: catalog)
        )
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
    ]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.topRated.isEmpty && viewModel.others.isEmpty {
                LoadingView()
            } else if let error = viewModel.errorMessage, viewModel.topRated.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.load() }
                }
            } else {
                content
            }
        }
        .navigationTitle(viewModel.name.capitalized)
        .task { await viewModel.load() }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                productSection(title: "Top Rated", products: viewModel.topRated)
                if !viewModel.others.isEmpty {
                    productSection(title: "More in this category", products: viewModel.others)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }

    private func productSection(title: String, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.title)

            if products.isEmpty {
                EmptyStateView(title: "No products yet")
                    .frame(height: 120)
            } else {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                    ForEach(products) { product in
                        NavigationLink(value: AppRoute.product(id: product.id)) {
                            ProductTile(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
