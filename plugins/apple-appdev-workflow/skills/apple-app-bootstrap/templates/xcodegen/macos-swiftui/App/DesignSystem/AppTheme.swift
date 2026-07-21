import SwiftUI

enum AppTheme {
    enum Spacing {
        static let screen: CGFloat = 32
        static let section: CGFloat = 24
        static let group: CGFloat = 18
        static let item: CGFloat = 10
        static let card: CGFloat = 24
        static let maxContentWidth: CGFloat = 920
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
                Color.accentColor.opacity(0.12),
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .controlBackgroundColor)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
