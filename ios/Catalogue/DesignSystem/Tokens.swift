import SwiftUI

/// Look-and-feel seam: screens compose these tokens instead of hardcoding style.
enum Theme {
    enum Color {
        static let background = SwiftUI.Color(.systemBackground)
        static let secondaryBackground = SwiftUI.Color(.secondarySystemBackground)
        static let primaryText = SwiftUI.Color.primary
        static let secondaryText = SwiftUI.Color.secondary
        static let accent = SwiftUI.Color.accentColor
        static let border = SwiftUI.Color(.separator)
        static let danger = SwiftUI.Color.red
        static let success = SwiftUI.Color.green
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }

    enum Typography {
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.caption
        static let price = Font.title3.weight(.bold)
    }
}
