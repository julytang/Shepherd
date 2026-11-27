// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdRemote",
    platforms: [.macOS("27.0"), .iOS("27.0")],
    products: [
        .library(name: "ShepherdRemote", targets: ["ShepherdRemote"]),
    ],
    dependencies: [
        .package(path: "../ShepherdModels"),
    ],
    targets: [
        .target(name: "ShepherdRemote", dependencies: ["ShepherdModels"]),
        .testTarget(name: "ShepherdRemoteTests", dependencies: ["ShepherdRemote"]),
    ],
    swiftLanguageModes: [.v6]
)
