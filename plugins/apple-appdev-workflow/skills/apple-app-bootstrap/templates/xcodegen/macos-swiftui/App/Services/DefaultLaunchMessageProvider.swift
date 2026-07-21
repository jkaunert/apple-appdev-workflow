struct DefaultLaunchMessageProvider: LaunchMessageProviding {
    func messages() -> [String] {
        [
            "Capture the product outcome and acceptance criteria before adding features.",
            "Keep views pure and push service or persistence decisions behind explicit boundaries.",
            "Add Swift Testing coverage for the first feature slice before expanding scope."
        ]
    }
}
