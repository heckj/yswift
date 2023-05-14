// swift-tools-version:5.6

import PackageDescription

var globalSwiftSettings: [PackageDescription.SwiftSetting] = []
#if swift(>=5.7)
    globalSwiftSettings.append(.unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"]))
    /*
     Summation from https://www.donnywals.com/enabling-concurrency-warnings-in-xcode-14/
     Set `strict-concurrency` to `targeted` to enforce Sendable and actor-isolation
     checks in your code. This explicitly verifies that `Sendable` constraints are
     met when you mark one of your types as `Sendable`.

     This mode is essentially a bit of a hybrid between the behavior that's intended
     in Swift 6, and the default in Swift 5.7. Use this mode to have a bit of
     checking on your code that uses Swift concurrency without too many warnings
     and / or errors in your current codebase.

     Set `strict-concurrency` to `complete` to get the full suite of concurrency
     constraints, essentially as they will work in Swift 6.
     */
#endif

let package = Package(
    name: "YSwift",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "YSwift", targets: ["YSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        // We are using a local file reference to an XCFramework, which is functional
        // on the tags for this package because the XCFramework.zip file is committed with
        // those specific release points. This does, however, cause a few awkward issues,
        // in particular it means that swift-docc-plugin doesn't operate correctly as the
        // process to retrieve the symbols from this and the XCFramework fails within
        // Swift Package Manager. Building documentation within Xcode works perfectly fine,
        // but if you're attempting to generate HTML documentation, use the script
        // `./scripts/build-ghpages-docs.sh`.
        //
        // If you're working from source, or a branch without an existing xcframework.zip,
        // use the script `./scripts/build-xcframework.sh` to create the library locally.
        // This script _does_ expect that you have Rust installed locally in order to function.
        .binaryTarget(
            name: "yniffiFFI",
            // Uncomment `path`, and comment out url and checksum, for local development
            // path: "./lib/yniffiFFI.xcframework"
            url: "https://github.com/heckj/yswift/releases/download/0.1.0/yniffiFFI.xcframework.zip",
            checksum: "9aa2dd069662613b66749a257d753fc7007afe4817278edfd6cc902de94b5f6c"
        ),
        .target(
            name: "Yniffi",
            dependencies: ["yniffiFFI"],
            path: "lib/swift/scaffold"
        ),
        .target(
            name: "YSwift",
            dependencies: ["Yniffi"],
            swiftSettings: globalSwiftSettings
        ),
        .testTarget(
            name: "YSwiftTests",
            dependencies: ["YSwift"]
        ),
    ]
)
