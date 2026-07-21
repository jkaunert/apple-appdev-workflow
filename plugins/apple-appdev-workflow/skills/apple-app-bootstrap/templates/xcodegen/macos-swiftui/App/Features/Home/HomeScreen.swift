import SwiftUI

struct HomeScreen: View {
    struct Model: Sendable {
        let appName: String
        let messages: [String]
    }

    let model: Model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var messageIndex = 0
    private let messageTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                        HeroCard(appName: model.appName, message: currentMessage)
                        HandoffGrid()
                    }
                    .frame(maxWidth: AppTheme.Spacing.maxContentWidth, alignment: .leading)
                    .padding(AppTheme.Spacing.screen)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(model.appName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    StatusPill(text: "Bootstrap-ready")
                }
            }
            .onReceive(messageTimer) { _ in
                guard model.messages.count > 1, reduceMotion == false else { return }
                messageIndex = (messageIndex + 1) % model.messages.count
            }
        }
    }

    private var currentMessage: String {
        guard !model.messages.isEmpty else {
            return "Define the first product milestone in the core development context."
        }
        return model.messages[messageIndex]
    }
}

private struct HeroCard: View {
    let appName: String
    let message: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.section) {
                AppIconPlaceholder(size: 96)
                TitleBlock(appName: appName, message: message)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.group) {
                AppIconPlaceholder(size: 84)
                TitleBlock(appName: appName, message: message)
            }
        }
        .padding(AppTheme.Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appName). \(message)")
    }
}

private struct TitleBlock: View {
    let appName: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.item) {
            Text("Ready for the first slice")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            Text(appName)
                .font(AppTheme.Typography.hero)
                .minimumScaleFactor(0.68)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HandoffGrid: View {
    private let columns = [
        GridItem(.adaptive(minimum: 240), spacing: AppTheme.Spacing.group, alignment: .top)
    ]

    private let tiles = [
        HandoffTile.Model(
            symbolName: "scope",
            title: "Scope",
            detail: "Capture the product problem and first milestone before implementation."
        ),
        HandoffTile.Model(
            symbolName: "arrow.triangle.branch",
            title: "Branch",
            detail: "Create the first topic branch from the reported bootstrap handoff point."
        ),
        HandoffTile.Model(
            symbolName: "checkmark.seal",
            title: "Validate",
            detail: "Use XcodeBuildMCP build and test validation before feature work."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.group) {
            Text("Bootstrap handoff")
                .font(AppTheme.Typography.title)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: columns, alignment: .leading, spacing: AppTheme.Spacing.group) {
                ForEach(tiles) { tile in
                    HandoffTile(model: tile)
                }
            }
        }
        .padding(AppTheme.Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct HandoffTile: View {
    struct Model: Identifiable {
        let symbolName: String
        let title: String
        let detail: String

        var id: String { title }
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.item) {
            Image(systemName: model.symbolName)
                .font(AppTheme.Typography.title)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text(model.title)
                .font(AppTheme.Typography.callout)

            Text(model.detail)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Spacing.group)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct StatusPill: View {
    let text: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.item) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            Text(text)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

private struct AppIconPlaceholder: View {
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(AppTheme.Gradients.hero)
            .overlay(
                Image(systemName: "macwindow")
                    .font(.system(size: size * 0.34, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .frame(width: size, height: size)
            .shadow(color: Color.accentColor.opacity(0.20), radius: 18, x: 0, y: 10)
            .accessibilityHidden(true)
    }
}

#Preview {
    HomeScreen(
        model: HomeScreen.Model(
            appName: "Preview App",
            messages: [
                "Model dependencies at the composition root.",
                "Keep SwiftUI views deterministic and testable."
            ]
        )
    )
    .frame(width: 760, height: 520)
}
