import Fluent
import FluentMySQLDriver
import FluentSQLiteDriver
import Gatekeeper
import JWT
import NIOSSL
import SotoCore
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    #warning("Production is missing. There are only testing and development")

    if app.environment == .testing {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        app.databases
            .use(.mysql(hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                        port: Environment.get("DATABASE_PORT")
                            .flatMap(Int.init(_:)) ??
                            MySQLConfiguration
                            .ianaPortNumber,
                        username: Environment
                            .get("DATABASE_USERNAME") ??
                            "vapor_username",
                        password: Environment
                            .get("DATABASE_PASSWORD") ??
                            "vapor_password",
                        database: Environment
                            .get("DATABASE_NAME") ?? "vapor_database"),
                 as: .mysql)
    }

    app.migrations.add(CreateCategoryMigration())
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateUserInfosMigration())
    app.migrations.add(CreateWorkshopMigration())
    app.migrations.add(CreateWorkshopInfosMigration())
    app.migrations.add(CreateReservationMigration())
    app.migrations.add(CreateBoothCountryMigration())
    app.migrations.add(CreateBoothCountryTranslationMigration())
    app.migrations.add(CreateBoothMigration())

    if app.environment == .development {
        app.migrations.add(AddMockDataMigration())
    }

    try await app.autoMigrate()

    let corsConfiguration = CORSMiddleware
        .Configuration(allowedOrigin: .any([
            "http://localhost:8080",
            "http://127.0.0.1:8080",
            "http://localhost:5500",
            "http://127.0.0.1:5500",
        ]),
        allowedMethods: [
            .GET,
            .POST,
            .PUT,
            .PATCH,
            .DELETE,
            .OPTIONS,
        ],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
        ],
        cacheExpiration: 10)
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware, at: .beginning)

    app.caches.use(.memory)
    if app.environment != .testing {
        app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
        app.middleware.use(GatekeeperMiddleware())
    }

    if app.environment == .development {
        let awsClient =
            AWSClient(credentialProvider: .static(accessKeyId: Environment.get("R2_ACCESS_KEY_ID")!,
                                                  secretAccessKey: Environment
                                                      .get("R2_SECRET_ACCESS_KEY")!))
        app.services.awsClient.use { _ in awsClient }
    }

    // register routes
    try routes(app)

    if app.environment == .development {
        await app.jwt.keys.add(hmac: .init(from: Environment.get("JWT_SECRET_KEY")!),
                               digestAlgorithm: .sha256,
                               kid: "basic")
    } else if app.environment == .testing {
        await app.jwt.keys.add(hmac: .init(from: "test-only-jwt-secret-key-32-bytes-minimum!"),
                               digestAlgorithm: .sha256,
                               kid: "basic")
    }
}
