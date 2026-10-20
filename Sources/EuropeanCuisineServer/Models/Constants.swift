//
//  Constants.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 14/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum Constants {
    static let defaultLocale: String = "en"

    enum OpeningHours {
        static let startHour: Int = 8
        static let endHour: Int = 18
        static let intervalMinutes: Int = 15
    }

    enum Booth {
        enum Name {
            static let validator: Validator<String> = .count(1 ... 100)
        }

        enum About {
            static let validator: Validator<String> = .count(1 ... 1000)
        }

        enum PictureURL {
            static let validator: Validator<String> = .count(1 ... 500)
                && .url
        }

        enum Location {
            static let validator: Validator<String> = .count(1 ... 100)
        }
    }

    enum BoothCountry {
        enum Code {
            static let validator: Validator<String> = .pattern("^[A-Z]{3}$")
        }
    }

    enum BoothCountryTranslation {
        enum Locale {
            static let validator: Validator<String> = .pattern("^[a-z]{2}$")
        }

        enum Name {
            static let validator: Validator<String> = .count(1 ... 100)
        }
    }

    enum Category {
        enum Name {
            static let validator: Validator<String> = .count(1 ... 100)
        }
    }

    enum Workshop {
        enum Name {
            static let validator: Validator<String> = .count(1 ... 100)
        }

        enum CapacityMax {
            static let validator: Validator<UInt16> = .range(1 ... 60000)
        }

        enum Description {
            static let validator: Validator<String> = .count(1 ... 1000)
        }
    }

    enum User {
        enum Name {
            static let validator: Validator<String> = .count(1 ... 100)
        }

        enum Email {
            static let validator: Validator<String> = .count(1 ... 254) && .email
        }

        enum Password {
            static let validator: Validator<String> = .count(12 ... 100)
        }
    }
}
