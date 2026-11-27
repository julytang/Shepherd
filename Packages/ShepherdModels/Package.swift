// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdModels",
    platforms: [.macOS("27.0"), .iOS("27.0")],
    products: [
        .library(name: "ShepherdModels", targets: ["ShepherdModels"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ShepherdModels", dependencies: []),
        .testTarget(name: "ShepherdModelsTests", dependencies: ["ShepherdModels"]),
    ],
    swiftLanguageModes: [.v6]
)
