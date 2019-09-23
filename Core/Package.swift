// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Core",
            type: .static,
            targets: ["Core"])
    ],
    dependencies: [
        .package(path: "../Common")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["Common"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Common", "Core"])
    ]
)
