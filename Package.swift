// swift-tools-version: 6.3

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
            name: "Bit Primitives Core",
            targets: ["Bit Primitives Core"]
        ),
        .library(
            name: "Bit Boolean Primitives",
            targets: ["Bit Boolean Primitives"]
        ),
        .library(
            name: "Bit Field Primitives",
            targets: ["Bit Field Primitives"]
        ),
        .library(
            name: "Bit Primitives Standard Library Integration",
            targets: ["Bit Primitives Standard Library Integration"]
        ),
        .library(
            name: "Bit Primitives Test Support",
            targets: ["Bit Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-algebra-field-primitives"),
        .package(path: "../swift-cardinal-primitives"),
        .package(path: "../swift-finite-primitives"),
        .package(path: "../swift-hash-primitives"),
        .package(path: "../swift-identity-primitives"),
    ],
    targets: [
        .target(
            name: "Bit Primitives",
            dependencies: [
                "Bit Primitives Core",
                "Bit Boolean Primitives",
                "Bit Field Primitives",
                "Bit Primitives Standard Library Integration",
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
            ]
        ),
        .target(
            name: "Bit Primitives Core",
            dependencies: []
        ),
        .target(
            name: "Bit Boolean Primitives",
            dependencies: [
                "Bit Primitives Core",
            ]
        ),
        .target(
            name: "Bit Field Primitives",
            dependencies: [
                "Bit Boolean Primitives",
                .product(name: "Algebra Field Primitives", package: "swift-algebra-field-primitives"),
            ]
        ),
        .target(
            name: "Bit Primitives Standard Library Integration",
            dependencies: [
                "Bit Boolean Primitives",
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
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
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
