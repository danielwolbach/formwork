// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "FormworkKit",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "FormworkKit", targets: ["FormworkKit"]),
    ],
    targets: [
        .target(name: "FormworkKit"),
    ]
)
