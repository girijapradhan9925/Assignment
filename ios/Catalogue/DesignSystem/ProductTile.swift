import SwiftUI

struct ProductTile: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            RemoteImage(urlString: product.imageUrl)
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Theme.Color.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))

            Text(product.title)
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Color.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: Theme.Spacing.xs) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Color.accent)
                Spacer(minLength: 0)
                Label(
                    String(format: "%.1f", product.rating.rate),
                    systemImage: "star.fill"
                )
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Color.secondaryText)
            }
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Theme.Color.border, lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), \(product.price, format: .currency(code: "USD")), rating \(product.rating.rate)")
    }
}
