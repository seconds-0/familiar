// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PaletteApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PaletteApp",
            targets: ["PaletteApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.22.0")
    ],
    targets: [
        .executableTarget(
            name: "PaletteApp",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/PaletteApp"
        )
    ]
)
