import SwiftUI

struct LoadingView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ProgressView()
            Text(message)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Color.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Spacing.lg)
    }
}
