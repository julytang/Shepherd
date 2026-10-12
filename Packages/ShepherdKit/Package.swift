// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShepherdKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ShepherdKit", targets: ["ShepherdKit"])
    ],
    targets: [
        .target(name: "ShepherdKit")
    ]
)
