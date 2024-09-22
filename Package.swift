// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PredicateView",
    platforms: [
        .macOS("14.0"),
        .iOS("17.0"),
        .tvOS("17.0"),
        .watchOS("10.0"),
        .visionOS("1.0"),
    ],
    products: [
        .library(name: "PredicateView", targets: ["PredicateView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NoahKamara/CompoundPredicate", from: "0.1.0"),
    ],
    targets: [
        .target(name: "PredicateView", dependencies: [
            .product(name: "CompoundPredicate", package: "CompoundPredicate"),
        ]),
    ]
)
