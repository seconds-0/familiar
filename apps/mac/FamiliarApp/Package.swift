// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FamiliarApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FamiliarApp",
            targets: ["FamiliarApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "FamiliarApp",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/FamiliarApp"
        ),
        .testTarget(
            name: "FamiliarAppTests",
            dependencies: ["FamiliarApp"],
            path: "Tests/FamiliarAppTests"
        )
    ]
)
