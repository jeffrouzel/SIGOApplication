//
//  WeatherModel.swift
//  SIGOApplication
//
//  Created by training2 on 4/20/26.
//

//  MARK: OpenWeatherMap API Response Model
// API Documentation: https://openweathermap.org/current

//  MARK: STRUCTURE
//{
//  "cod": "200",
//  "message": 0,
//  "cnt": 40,
//  "list": [
//    {
//      "dt": 1661871600,
//      "main": {
//        "temp": 296.76,
//        "feels_like": 296.98,
//        "temp_min": 296.76,
//        "temp_max": 297.87,
//        "pressure": 1015,
//        "sea_level": 1015,
//        "grnd_level": 933,
//        "humidity": 69,
//        "temp_kf": -1.11
//      },
//      "weather": [
//        {
//          "id": 500,
//          "main": "Rain",
//          "description": "light rain",
//          "icon": "10d"
//        }
//      ],
//      "clouds": {
//        "all": 100
//      },
//      "wind": {
//        "speed": 0.62,
//        "deg": 349,
//        "gust": 1.18
//      },
//      "visibility": 10000,
//      "pop": 0.32,
//      "rain": {
//        "3h": 0.26
//      },
//      "sys": {
//        "pod": "d"
//      },
//      "dt_txt": "2022-08-30 15:00:00"
//    },
//  ],
//  "city": {
//    "id": 3163858,
//    "name": "Zocca",
//    "coord": {
//      "lat": 44.34,
//      "lon": 10.99
//    },
//    "country": "IT",
//    "population": 4593,
//    "timezone": 7200,
//    "sunrise": 1661834187,
//    "sunset": 1661882248
//  }
//}

import Foundation

// MARK: MAIN PART

struct ForecastResponse: Codable, Sendable {
    let list: [ForecastItem]
    let city: City
}

// MARK: FORECAST ITEMS
struct ForecastItem: Codable, Sendable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double                // Probability of precipitation
    let rain: RainVolume?
    let sys: ForecastSys
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
        case dtTxt = "dt_txt"
    }
}

struct Main: Codable, Sendable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin   = "temp_min"
        case tempMax   = "temp_max"
    }
}

struct Weather: Codable, Sendable {
    let main: String
    let description: String
    let icon: String
}

struct Clouds: Codable, Sendable {
    let all: Int
}

struct Wind: Codable, Sendable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct RainVolume: Codable, Sendable {
    let threeHour: Double?         // Rain accumulation over last 3 hours (mm)

    enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

struct ForecastSys: Codable, Sendable {
    let pod: String
}

// MARK: CITY
struct City: Codable, Sendable {
    let name: String
    let coord: Coord
    let country: String
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

struct Coord: Codable, Sendable {
    let lon: Double
    let lat: Double
}
