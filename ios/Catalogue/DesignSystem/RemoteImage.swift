import SwiftUI

struct RemoteImage: View {
    let urlString: String
    var contentMode: ContentMode = .fit

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Theme.Color.secondaryBackground
                    ProgressView()
                }
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                ZStack {
                    Theme.Color.secondaryBackground
                    Image(systemName: "photo")
                        .foregroundStyle(Theme.Color.secondaryText)
                }
            @unknown default:
                Theme.Color.secondaryBackground
            }
        }
    }
}
