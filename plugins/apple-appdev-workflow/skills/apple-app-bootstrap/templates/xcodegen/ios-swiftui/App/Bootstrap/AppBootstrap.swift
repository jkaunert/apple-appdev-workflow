import SwiftUI

struct AppBootstrap {
    private let dependencies: AppDependencies

    static func live(appName: String) -> AppBootstrap {
        AppBootstrap(
            dependencies: AppDependencies(
                appName: appName,
                launchMessageProvider: DefaultLaunchMessageProvider()
            )
        )
    }

    @MainActor
    func makeRootView() -> some View {
        HomeScreen(
            model: HomeScreen.Model(
                appName: dependencies.appName,
                messages: dependencies.launchMessageProvider.messages()
            )
        )
    }
}

struct AppDependencies {
    let appName: String
    let launchMessageProvider: any LaunchMessageProviding
}
