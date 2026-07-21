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
                        NextStepsCard()
                    }
                    .frame(maxWidth: AppTheme.Spacing.maxContentWidth, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.screen)
                    .padding(.vertical, AppTheme.Spacing.section)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(model.appName)
            .navigationBarTitleDisplayMode(.inline)
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.group) {
            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: AppTheme.Spacing.group) {
                    AppIconPlaceholder(size: 112)
                    TitleBlock(appName: appName, lineLimit: 2)
                }
            } else {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.group) {
                    AppIconPlaceholder(size: 86)
                    TitleBlock(appName: appName, lineLimit: 1)
                }
            }

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            StatusPill(text: "Bootstrap-ready baseline")
        }
        .padding(AppTheme.Spacing.card)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appName). \(message)")
    }
}

private struct TitleBlock: View {
    let appName: String
    let lineLimit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.item) {
            Text("Ready for the first slice")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            Text(appName)
                .font(AppTheme.Typography.hero)
                .minimumScaleFactor(0.58)
                .lineLimit(lineLimit)
                .allowsTightening(true)
                .accessibilityAddTraits(.isHeader)
        }
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
        .padding(.vertical, 8)
        .background(.thinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

private struct NextStepsCard: View {
    private let steps = [
        "Confirm the product problem and first milestone.",
        "Create a topic branch before feature implementation.",
        "Run XcodeBuildMCP build and test validation after scaffold."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.group) {
            Text("Bootstrap handoff")
                .font(AppTheme.Typography.title)
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                Label {
                    Text(step)
                        .font(AppTheme.Typography.callout)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Text("\(index + 1)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.accentColor))
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(AppTheme.Spacing.card)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct AppIconPlaceholder: View {
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(AppTheme.Gradients.hero)
            .overlay(
                Image(systemName: "swift")
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .frame(width: size, height: size)
            .shadow(color: Color.accentColor.opacity(0.24), radius: 22, x: 0, y: 12)
            .accessibilityHidden(true)
    }
}

#Preview {
    HomeScreen(
        model: HomeScreen.Model(
            appName: "Preview App",
            messages: [
                "Wire the first dependency boundary.",
                "Replace starter copy with product intent."
            ]
        )
    )
}

#Preview("Accessibility text size") {
    HomeScreen(
        model: HomeScreen.Model(
            appName: "Preview App",
            messages: [
                "Check clipping and reading order before building features."
            ]
        )
    )
    .environment(\.dynamicTypeSize, .accessibility3)
}
