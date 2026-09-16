// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "YTGlass",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "YTGlass",
            path: "Sources/YTGlass",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
