// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdProviderCodex",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdProviderCodex", targets: ["ShepherdProviderCodex"]),
    ],
    dependencies: [
        .package(path: "../ShepherdProviderKit"),
    ],
    targets: [
        .target(name: "ShepherdProviderCodex", dependencies: ["ShepherdProviderKit"]),
        .testTarget(name: "ShepherdProviderCodexTests", dependencies: ["ShepherdProviderCodex"]),
    ],
    swiftLanguageModes: [.v6]
)
