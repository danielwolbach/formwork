// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "FormworkKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v27),
    ],
    products: [
        .library(
            name: "FormworkKit",
            targets: ["FormworkKit"]
        ),
    ],
    targets: [
        .target(
            name: "FormworkKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "FormworkKitTests",
            dependencies: ["FormworkKit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
