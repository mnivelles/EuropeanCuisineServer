import Fluent
import FluentMySQLDriver
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
        .Configuration(allowedOrigin: .custom("http://localhost:8080"),
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
    app.middleware.use(corsMiddleware)

    // register routes
    try routes(app)
}
