// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PredicateView",
    platforms: [
        .macOS("14.0"),
        .iOS("17.0"),
        .tvOS("17.0"),
        .watchOS("10.0")
    ],
    products: [
        .library(name: "PredicateView", targets: ["PredicateView"]),
    ],
    targets: [
        .target(name: "PredicateView"),
    ]
)
