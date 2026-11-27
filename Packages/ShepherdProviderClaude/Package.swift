// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdProviderClaude",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdProviderClaude", targets: ["ShepherdProviderClaude"]),
    ],
    dependencies: [
        .package(path: "../ShepherdProviderKit"),
    ],
    targets: [
        .target(name: "ShepherdProviderClaude", dependencies: ["ShepherdProviderKit"]),
        .testTarget(name: "ShepherdProviderClaudeTests", dependencies: ["ShepherdProviderClaude"]),
    ],
    swiftLanguageModes: [.v6]
)
