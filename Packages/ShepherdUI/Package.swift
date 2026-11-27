// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdUI",
    platforms: [.macOS("27.0"), .iOS("27.0")],
    products: [
        .library(name: "ShepherdUI", targets: ["ShepherdUI"]),
    ],
    dependencies: [
        .package(path: "../ShepherdModels"),
    ],
    targets: [
        .target(name: "ShepherdUI", dependencies: ["ShepherdModels"]),
        .testTarget(name: "ShepherdUITests", dependencies: ["ShepherdUI"]),
    ],
    swiftLanguageModes: [.v6]
)
