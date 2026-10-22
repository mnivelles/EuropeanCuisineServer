// swift-tools-version:6.3
import PackageDescription

let package = Package(name: "EuropeanCuisineServer",
                      platforms: [
                          .macOS(.v13),
                      ],
                      dependencies: [
                          // 💧 A server-side Swift web framework.
                          .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
                          // 🗄 An ORM for SQL and NoSQL databases.
                          .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
                          // 🐬 Fluent driver for MySQL.
                          .package(url: "https://github.com/vapor/fluent-mysql-driver.git",
                                   from: "4.8.0"),
                          // 🔵 Non-blocking, event-driven networking for Swift. Used for custom
                          // executors
                          .package(url: "https://github.com/apple/swift-nio.git", from: "2.101.0"),

                          .package(url: "https://github.com/nodes-vapor/gatekeeper.git",
                                   from: "4.0.0"),

                          .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),

                          .package(url: "https://github.com/soto-project/soto.git", from: "7.17.0"),
                      ],
                      targets: [
                          .executableTarget(name: "EuropeanCuisineServer",
                                            dependencies: [
                                                .product(name: "Fluent", package: "fluent"),
                                                .product(name: "FluentMySQLDriver",
                                                         package: "fluent-mysql-driver"),
                                                .product(name: "Vapor", package: "vapor"),
                                                .product(name: "NIOCore", package: "swift-nio"),
                                                .product(name: "NIOPosix", package: "swift-nio"),
                                                .product(name: "Gatekeeper", package: "gatekeeper"),
                                                .product(name: "JWT", package: "jwt"),
                                                .product(name: "SotoS3", package: "soto"),
                                            ],
                                            swiftSettings: swiftSettings),
                          .testTarget(name: "EuropeanCuisineServerTests",
                                      dependencies: [
                                          .target(name: "EuropeanCuisineServer"),
                                          .product(name: "VaporTesting", package: "vapor"),
                                      ],
                                      swiftSettings: swiftSettings),
                      ])

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
    ]
}
