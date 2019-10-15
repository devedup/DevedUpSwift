// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevedUpSwift",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "General",
            targets: ["General"]),
        .library(
            name: "Localisation",
            targets: ["Localisation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "General",
            dependencies: [],
            path: "Sources/General"),
        .target(
            name: "Localisation",
            dependencies: [],
            path: "Sources/Localisation"),
        .testTarget(
            name: "DevedUpSwiftTests",
            dependencies: ["General"]),
    ]
)
