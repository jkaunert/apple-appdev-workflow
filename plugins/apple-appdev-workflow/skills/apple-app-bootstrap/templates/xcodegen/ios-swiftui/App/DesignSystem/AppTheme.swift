import SwiftUI

enum AppTheme {
    enum Spacing {
        static let screen: CGFloat = 24
        static let section: CGFloat = 24
        static let group: CGFloat = 16
        static let item: CGFloat = 10
        static let card: CGFloat = 22
        static let maxContentWidth: CGFloat = 680
    }

    enum Typography {
        static let hero = Font.largeTitle.weight(.bold)
        static let title = Font.title2.weight(.semibold)
        static let body = Font.body
        static let callout = Font.callout.weight(.medium)
        static let caption = Font.footnote.weight(.medium)
    }

    enum Gradients {
        static let hero = LinearGradient(
            colors: [Color.accentColor, Color.accentColor.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let background = LinearGradient(
            colors: [
                Color.accentColor.opacity(0.16),
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
