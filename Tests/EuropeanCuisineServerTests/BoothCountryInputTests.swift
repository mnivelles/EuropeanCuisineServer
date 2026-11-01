@testable import EuropeanCuisineServer
import Testing
import Vapor

@Suite("BoothCountryInput validation")
struct BoothCountryInputTests {
    @Test(arguments: ["FRA", "JPN", "ESP", "GBR"])
    func `Valid codes`(code: String) throws {
        try BoothCountryInput.validate(json: #"{"code":"\#(code)"}"#)
    }

    @Test(arguments: ["", "F", "FR", "fr", "F1", " US", "FRANCE"])
    func `Invalid codes`(code: String) {
        #expect(throws: ValidationsError.self) {
            try BoothCountryInput.validate(json: #"{"code":"\#(code)"}"#)
        }
    }

    @Test
    func `Missing code field in JSON`() {
        #expect(throws: ValidationsError.self) {
            try BoothCountryInput.validate(json: "{}")
        }
    }
}
