import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }

    try app.register(collection: CategoryController())
    try app.register(collection: WorkshopController())
    try app.register(collection: BoothCountryController())
    try app.register(collection: BoothCountryTranslationController())
    try app.register(collection: BoothController())
    try app.register(collection: AuthController())
    try app.register(collection: UserController())
    try app.register(collection: ReservationController())
}
