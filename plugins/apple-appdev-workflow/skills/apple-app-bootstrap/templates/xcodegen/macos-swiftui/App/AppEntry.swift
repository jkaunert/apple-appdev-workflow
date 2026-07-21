import SwiftUI

@main
struct __APP_PRODUCT_NAME__App: App {
    private let bootstrap = AppBootstrap.live(appName: "__APP_NAME__")

    var body: some Scene {
        WindowGroup {
            bootstrap.makeRootView()
                .frame(minWidth: 720, minHeight: 480)
        }
        .windowResizability(.contentSize)
    }
}
