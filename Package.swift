// swift-tools-version: 6.3.1

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
            name: "Bit Primitive",
            targets: ["Bit Primitive"]
        ),
        .library(
            name: "Bit Pattern Primitives",
            targets: ["Bit Pattern Primitives"]
        ),
        .library(
            name: "Bit Primitives",
            targets: ["Bit Primitives"]
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
        .package(url: "https://github.com/swift-primitives/swift-comparison-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-equation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-hash-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Bit Primitives",
            dependencies: [
                "Bit Primitive",
                "Bit Pattern Primitives",
                "Bit Primitives Standard Library Integration",
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
            ]
        ),
        .target(
            name: "Bit Primitive",
            dependencies: []
        ),

        // MARK: - Pattern
        //
        // Carrier-dependent bit-pattern operations (`Bit.Pattern<Carrier>`
        // generic enum + nested `Mask` struct + ring operators, plus the
        // `Ones`/`Zeros` rank/select word kernels). Leaf variant — zero
        // external deps (uses only stdlib FixedWidthInteger & UnsignedInteger
        // constraints over the carrier ring Z/2^w).
        .target(
            name: "Bit Pattern Primitives",
            dependencies: [
                "Bit Primitive",
            ]
        ),
        .target(
            name: "Bit Primitives Standard Library Integration",
            dependencies: [
                "Bit Primitive",
            ]
        ),
        .target(
            name: "Bit Primitives Test Support",
            dependencies: [
                "Bit Primitives"
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
