// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "IterlyCore",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "IterlyCore",
            targets: ["IterlyCore"]
        )
    ],
    targets: [
        .target(
            name: "IterlyCore"
        )
    ]
)
