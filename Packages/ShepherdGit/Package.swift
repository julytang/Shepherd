// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShepherdGit",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "ShepherdGit", targets: ["ShepherdGit"]),
    ],
    dependencies: [
        .package(path: "../ShepherdModels"),
    ],
    targets: [
        .target(name: "ShepherdGit", dependencies: ["ShepherdModels"]),
        .testTarget(name: "ShepherdGitTests", dependencies: ["ShepherdGit"]),
    ],
    swiftLanguageModes: [.v6]
)
