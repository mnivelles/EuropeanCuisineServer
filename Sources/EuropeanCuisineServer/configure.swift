import Fluent
import FluentMySQLDriver
import Gatekeeper
import JWT
import NIOSSL
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases
        .use(DatabaseConfigurationFactory
            .mysql(hostname: Environment.get("DATABASE_HOST") ?? "localhost",
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

    app.migrations.add(CreateCategoryMigration())
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateUserInfosMigration())
    app.migrations.add(CreateWorkshopMigration())
    app.migrations.add(CreateWorkshopInfosMigration())
    app.migrations.add(CreateReservationMigration())
    app.migrations.add(CreateBoothCountryMigration())
    app.migrations.add(CreateBoothCountryTranslationMigration())
    app.migrations.add(CreateBoothMigration())

    #warning("retirer ajout des mock data quand en production")
    app.migrations.add(AddMockDataMigration())

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
    app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
    app.middleware.use(GatekeeperMiddleware())

    // register routes
    try routes(app)

    await app.jwt.keys.add(hmac: .init(from: Environment.get("JWT_SECRET_KEY")!),
                           digestAlgorithm: .sha256,
                           kid: "basic")
}
