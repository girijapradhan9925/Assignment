import Foundation

@MainActor
final class AppContainer {
    let catalog: CatalogService

    init(catalog: CatalogService? = nil) {
        if let catalog {
            self.catalog = catalog
        } else {
            let client = APIClient(baseURL: AppConfig.apiBaseURL)
            self.catalog = RemoteCatalogService(client: client)
        }
    }
}
