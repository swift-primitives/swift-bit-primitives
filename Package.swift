// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-bit-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Bit Primitives",
            targets: ["Bit Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-algebra-primitives"),
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-test-primitives"),
    ],
    targets: [
        .target(
            name: "Bit Primitives",
            dependencies: [
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
            ]
        ),
        .testTarget(
            name: "Bit Primitives Tests",
            dependencies: [
                "Bit Primitives",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
