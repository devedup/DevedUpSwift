// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevedUpSwift",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DevedUpSwiftFoundation",
            targets: ["DevedUpSwiftFoundation"]),
        .library(
            name: "DevedUpSwiftIAP",
            targets: ["DevedUpSwiftIAP"]),
        .library(
            name: "DevedUpSwiftUI",
            targets: ["DevedUpSwiftUI"]),
        .library(
            name: "DevedUpSwiftLocalisation",
            targets: ["DevedUpSwiftLocalisation"]),
        .library(
            name: "DevedUpSwiftNetwork",
            targets: ["DevedUpSwiftNetwork"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DevedUpSwiftFoundation",
            dependencies: ["DevedUpSwiftLocalisation"],
            path: "Sources/Foundation"),
        .target(
            name: "DevedUpSwiftIAP",
            dependencies: ["DevedUpSwiftFoundation"],
            path: "Sources/InAppPurchase/Source"),
        .target(
            name: "DevedUpSwiftLocalisation",
            dependencies: [],
            path: "Sources/Localisation"),
        .target(
            name: "DevedUpSwiftUI",
            dependencies: ["DevedUpSwiftLocalisation", "DevedUpSwiftFoundation"],
            path: "Sources/UI"),
        .target(
            name: "DevedUpSwiftNetwork",
            dependencies: ["DevedUpSwiftFoundation"],
            path: "Sources/Network"),
        .testTarget(
            name: "DevedUpSwiftFoundationTests",
            dependencies: ["DevedUpSwiftFoundation"]),
    ]
)
