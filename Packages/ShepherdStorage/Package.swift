// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdStorage",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdStorage", targets: ["ShepherdStorage"]),
    ],
    dependencies: [
        .package(path: "../ShepherdModels"),
    ],
    targets: [
        .target(name: "ShepherdStorage", dependencies: ["ShepherdModels"]),
        .testTarget(name: "ShepherdStorageTests", dependencies: ["ShepherdStorage"]),
    ],
    swiftLanguageModes: [.v6]
)
