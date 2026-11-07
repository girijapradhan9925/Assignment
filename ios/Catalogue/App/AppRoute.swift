import Foundation

enum AppRoute: Hashable {
    case category(slug: String, name: String)
    case product(id: Int)
    case enquiry(productId: Int, productTitle: String)
}
