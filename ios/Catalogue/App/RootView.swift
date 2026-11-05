import SwiftUI

struct RootView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(catalog: container.catalog)
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                SearchView(catalog: container.catalog)
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: AppRoute) -> some View {
        switch route {
        case let .category(slug, name):
            CategoryView(slug: slug, name: name, catalog: container.catalog)
        case let .product(id):
            ProductDetailView(productId: id, catalog: container.catalog)
        case let .enquiry(productId, productTitle):
            EnquiryView(
                productId: productId,
                productTitle: productTitle,
                catalog: container.catalog
            )
        }
    }
}
