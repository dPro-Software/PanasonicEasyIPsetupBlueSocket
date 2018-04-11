// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PanasonicEasyIPsetupBlueSocket",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PanasonicEasyIPsetupBlueSocket",
            targets: ["PanasonicEasyIPsetupBlueSocket"]),
    ],
    dependencies: [
		.package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.2"),
		.package(url: "https://github.com/svdo/swift-netutils", from: "4.0.2"),
		.package(url: "../PanasonicEasyIPsetupCore", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PanasonicEasyIPsetupBlueSocket",
            dependencies: ["Socket", "PanasonicEasyIPsetupCore", "NetUtils"]),
        .testTarget(
            name: "PanasonicEasyIPsetupBlueSocketTests",
            dependencies: ["PanasonicEasyIPsetupBlueSocket"]),
    ]
)
