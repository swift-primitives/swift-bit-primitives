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
        )
    ],
    dependencies: [
        .package(path: "../swift-algebra-primitives"),
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-array-primitives"),
        .package(path: "../swift-set-primitives")
    ],
    targets: [
        .target(
            name: "Bit Primitives",
            dependencies: [
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Array Primitives", package: "swift-array-primitives"),
                .product(name: "Set Primitives", package: "swift-set-primitives")
            ]
        ),
        .testTarget(
            name: "Bit Primitives Tests",
            dependencies: ["Bit Primitives"]
        )
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
