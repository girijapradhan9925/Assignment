import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(catalog: CatalogService) {
        _viewModel = State(initialValue: SearchViewModel(catalog: catalog))
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.xs) {
                TextField("Search products", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.search() }
                    }

                Button("Search") {
                    Task { await viewModel.search() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)

            content
        }
        .navigationTitle("Search")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView(message: "Searching…")
        } else if let error = viewModel.errorMessage {
            ErrorStateView(message: error) {
                Task { await viewModel.search() }
            }
        } else if !viewModel.hasSearched {
            EmptyStateView(
                title: "Find a product",
                subtitle: "Enter a search term and tap Search."
            )
        } else if viewModel.results.isEmpty {
            EmptyStateView(
                title: "No matches",
                subtitle: "Try a different term."
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                    ForEach(viewModel.results) { product in
                        NavigationLink(value: AppRoute.product(id: product.id)) {
                            ProductTile(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.Spacing.md)
            }
        }
    }
}
