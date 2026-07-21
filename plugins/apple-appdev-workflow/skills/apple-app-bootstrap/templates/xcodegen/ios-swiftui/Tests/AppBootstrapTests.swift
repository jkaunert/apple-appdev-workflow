import Testing
@testable import __APP_PRODUCT_NAME__

struct AppBootstrapTests {
    @Test
    func launchMessagesAreSeeded() {
        let provider = DefaultLaunchMessageProvider()

        #expect(provider.messages().isEmpty == false)
    }
}
