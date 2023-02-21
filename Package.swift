// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cdlztosqlite",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "cdlztosqlite", targets: ["cdlztosqlite"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.11.5"),
        .package(url: "https://github.com/ckanchan/CDKSwiftOracc", from: "0.5.6"),
        .package(url: "https://github.com/weichsel/zipfoundation", from: "0.9.6")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
            name: "cdlztosqlite",
            dependencies: [
                .product(name: "CDKSwiftOracc", package: "cdkswiftoracc"),
                .product(name:"SQLite", package:"SQLite.swift"),
                .product(name:"ZIPFoundation", package: "zipfoundation")
            ]
        )
    ]
)

