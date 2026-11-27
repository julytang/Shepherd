// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdProviderACP",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdProviderACP", targets: ["ShepherdProviderACP"]),
    ],
    dependencies: [
        .package(path: "../ShepherdProviderKit"),
    ],
    targets: [
        .target(name: "ShepherdProviderACP", dependencies: ["ShepherdProviderKit"]),
        .testTarget(name: "ShepherdProviderACPTests", dependencies: ["ShepherdProviderACP"]),
    ],
    swiftLanguageModes: [.v6]
)
