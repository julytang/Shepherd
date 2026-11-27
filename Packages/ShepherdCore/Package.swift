// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdCore",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdCore", targets: ["ShepherdCore"]),
    ],
    dependencies: [
        .package(path: "../ShepherdModels"),
        .package(path: "../ShepherdProviderKit"),
    ],
    targets: [
        .target(name: "ShepherdCore", dependencies: ["ShepherdModels", "ShepherdProviderKit"]),
        .testTarget(name: "ShepherdCoreTests", dependencies: ["ShepherdCore"]),
    ],
    swiftLanguageModes: [.v6]
)
