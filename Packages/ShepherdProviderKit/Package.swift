// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdProviderKit",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdProviderKit", targets: ["ShepherdProviderKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ShepherdProviderKit", dependencies: []),
        .testTarget(name: "ShepherdProviderKitTests", dependencies: ["ShepherdProviderKit"]),
    ],
    swiftLanguageModes: [.v6]
)
