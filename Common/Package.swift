// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Common",
            type: .static,
            targets: ["Common"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: []),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"])
    ]
)
