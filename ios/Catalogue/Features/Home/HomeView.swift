import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let catalog: CatalogService

    init(catalog: CatalogService) {
        self.catalog = catalog
        _viewModel = State(initialValue: HomeViewModel(catalog: catalog))
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
    ]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.featured.isEmpty {
                LoadingView()
            } else if let error = viewModel.errorMessage, viewModel.featured.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.load() }
                }
            } else {
                content
            }
        }
        .navigationTitle("Catalogue")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                categoriesSection
                featuredSection
            }
            .padding(Theme.Spacing.md)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Categories")
                .font(Theme.Typography.title)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(value: AppRoute.category(slug: category.slug, name: category.name)) {
                            Text(category.name.capitalized)
                                .font(Theme.Typography.caption)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                                .background(Theme.Color.secondaryBackground)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Top Rated")
                .font(Theme.Typography.title)

            LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                ForEach(viewModel.featured) { product in
                    NavigationLink(value: AppRoute.product(id: product.id)) {
                        ProductTile(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
