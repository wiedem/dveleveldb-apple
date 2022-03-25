// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "DVELevelDB",
    platforms: [
        .iOS(.v12),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "DVELevelDB",
            targets: ["DVELevelDB", "DVELevelDB_ObjC"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DVELevelDB",
            dependencies: ["DVELevelDB_ObjC"],
            path: "Sources",
            exclude: [],
            publicHeadersPath: nil
        ),
        .target(
            name: "DVELevelDB_ObjC",
            dependencies: [],
            path: "CSources",
            exclude: [],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("leveldb"),
                .define("LEVELDB_PLATFORM_POSIX=1"),
                // .define("NDEBUG"),
            ]
        ),
        .testTarget(
            name: "DVELevelDBTests",
            dependencies: ["DVELevelDB"]
        ),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx11
)
