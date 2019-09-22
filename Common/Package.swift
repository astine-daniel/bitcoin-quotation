// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Common",
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
