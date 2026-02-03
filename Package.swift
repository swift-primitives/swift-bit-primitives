// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-bit-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Bit Primitives",
            targets: ["Bit Primitives"]
        ),
        .library(
            name: "Bit Primitives Test Support",
            targets: ["Bit Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-algebra-primitives"),
        .package(path: "../swift-hash-primitives"),
        .package(path: "../swift-identity-primitives"),
    ],
    targets: [
        .target(
            name: "Bit Primitives",
            dependencies: [
                "Bit Primitives Core",
                "Bit Primitives Standard Library Integration",
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
            ]
        ),
        .target(
            name: "Bit Primitives Core",
            dependencies: []
        ),
        .target(
            name: "Bit Primitives Standard Library Integration",
            dependencies: [
                "Bit Primitives Core",
            ]
        ),
        .target(
            name: "Bit Primitives Test Support",
            dependencies: [
                "Bit Primitives",
                .product(name: "Identity Primitives Test Support", package: "swift-identity-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Bit Primitives Tests",
            dependencies: [
                "Bit Primitives",
                "Bit Primitives Test Support",
            ],
            path: "Tests/Bit Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety()
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
