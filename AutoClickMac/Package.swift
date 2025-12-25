// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AutoClickMac",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "AutoClickMac"
        )
    ]
)
