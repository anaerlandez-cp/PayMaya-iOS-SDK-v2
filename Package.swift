// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "PayMayaSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "PayMayaSDK",
            targets: ["PayMayaSDK"]
        ),
    ],
    dependencies: [
        // Add Google SignIn dependency
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "9.1.0")
    ],
    targets: [
        .target(
            name: "PayMayaSDK",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            path: "PayMayaSDK"
        ),
        .testTarget(
            name: "PayMayaSDKTests",
            dependencies: ["PayMayaSDK"],
            path: "PayMayaSDKTests"
        )
    ]
)
