//
//  WeatherViewModel.swift
//  SIGOApplication
//
//  Created by training2 on 4/20/26.
//
import Foundation
class WeatherViewModel{
    var weather: ForecastResponse?
    var onWeatherUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    private let service: WeatherServiceProtocol

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }
    
    // FETCH BY CITY (use in list)
    func fetchWeather(city: String) {
        Task {
            do {
                let weather = try await service.fetchWeather(city: city)
                self.weather = weather
                self.onWeatherUpdate?()
            } catch {
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    // FETCH BY LONGITUDE AND LATITUDE (use in home)
    func fetchWeather(lat: Double, lon: Double) {
        Task {
            do {
                let weather = try await service.fetchWeather(lat: lat, lon: lon)
                self.weather = weather
                self.onWeatherUpdate?()
            } catch {
                self.onError?(error.localizedDescription)
            }
        }
    }

    // MARK: DATA
    var forecasts: [ForecastItem] = []

    var cityName: String {
        weather?.city.name ?? ""
    }

    var countryName: String {
        weather?.city.country ?? ""
    }

    // MARK: CURRENT CONDITIONS
    var temperatureText: String {
        guard let temp = weather?.list.first?.main.temp else { return "--" }
        return "\(Int(temp.rounded()))°C"
    }

    var feelsLikeText: String {
        guard let feelsLike = weather?.list.first?.main.feelsLike else { return "--" }
        return "Feels like \(Int(feelsLike.rounded()))°C"
    }

    var conditionText: String {
        weather?.list.first?.weather.first?.description.capitalized ?? "Unknown"
    }

    var humidityText: String {
        guard let humidity = weather?.list.first?.main.humidity else { return "--" }
        return "Humidity: \(humidity)%"
    }

    var sunriseText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunrise, timezone: weather.city.timezone)
    }

    var sunsetText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunset, timezone: weather.city.timezone)
    }
    
    var precipitationChance: String {
        guard let pop = weather?.list.first?.pop else { return "--" }
        return "\(Int((pop * 100).rounded()))%"
    }

    // MARK: Logic for WeatherIcons

    var isDay: Bool {
        guard let weather,
              let dt = weather.list.first?.dt else { return true }
        let current = dt + weather.city.timezone
        return current >= weather.city.sunrise + weather.city.timezone &&
        current < weather.city.sunset + weather.city.timezone
    }

    var weatherIconName: String {
        let condition = weather?.list.first?.weather.first?.main ?? "Clear"
        switch condition.lowercased() {
        case "clear":
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case "clouds":
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case "rain", "drizzle":
            return "cloud.rain.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "snowflake"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }


    // MARK: Private helpers
    private func formatTime(_ unix: Int, timezone: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unix))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone(secondsFromGMT: timezone)
        return formatter.string(from: date)
    }
}

