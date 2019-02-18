// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Helix",
    products: [
        .library(
            name: "Helix",
            targets: ["Helix"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Helix",
            dependencies: []),
        .testTarget(
            name: "HelixTests",
            dependencies: ["Helix"]),
    ]
)
