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
    
    // MARK: HEAD DATA
    var cityName: String {
        weather?.city.name ?? ""
    }

    var countryName: String {
        weather?.city.country ?? ""
    }
    
    var sunriseText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunrise, timezone: weather.city.timezone)
    }

    var sunsetText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunset, timezone: weather.city.timezone)
    }
    
    // MARK: FOR WEATHER FORECAST LIST (up to 40 items, every 3hrs for 5 days)
    
    var selectedIndex: Int = 0 {
        didSet {
            // clamp to valid range so callers don't have to worry about bounds
            guard let list = weather?.list, !list.isEmpty else { return }
            selectedIndex = max(0, min(selectedIndex, list.count - 1))
        }
    }

    // For changing of forecast based on index (3hrs interval per index)
    private var selectedForecast: ForecastItem? {
        weather?.list[selectedIndex]
    }
    // MARK: FORECAST DATA
    // Main items
    var temperatureText: String {
        guard let temp = selectedForecast?.main.temp else { return "--°C" }
        return "\(Int(temp.rounded()))°C"
    }
    
    var feelsLikeText: String {
        guard let feelsLike = selectedForecast?.main.feelsLike else { return "--°C" }
        return "Feels like \(Int(feelsLike.rounded()))°C"
    }
    
    var minTempText: String {
        guard let minTemp = selectedForecast?.main.tempMin else { return "--°C" }
        return "Min: \(Int(minTemp.rounded()))°C"
    }
    
    var maxTempText: String {
        guard let maxTemp = selectedForecast?.main.tempMax else { return "--°C" }
        return "Max: \(Int(maxTemp.rounded()))°C"
    }
    
    var humidityText: String {
        guard let humidity = selectedForecast?.main.humidity else { return "--" }
        return "Humidity: \(humidity)%"
    }
    
    // Weather Items
    var conditionText: String {
        selectedForecast?.weather.first?.description.capitalized ?? "Unknown"
    }
    // Rain Related
    var precipitationChance: String {
        guard let pop = selectedForecast?.pop else { return "--" }
        return "\(Int((pop * 100).rounded()))%"
    }
    
    var rainDropSize: String? {
        guard let threeHourRainData = selectedForecast?.rain else { return "--" }
        return "\(threeHourRainData) mm"
    }

    // MARK: Logic for WeatherIcons

    var isDay: Bool {
        guard let weather,
              let dt = selectedForecast?.dt else { return true }
        let current = dt + weather.city.timezone
        return current >= weather.city.sunrise + weather.city.timezone &&
        current < weather.city.sunset + weather.city.timezone
    }

    var weatherIconName: String {
        let condition = selectedForecast?.weather.first?.main ?? "Clear"
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
    
    // MARK: FOR FORECAST DROPDOWN
    // Labels
    func labelForIndex(_ index: Int) -> String {
        if index == 0 { return "Current" }
        
        let totalHours = index * 3
        let days = totalHours / 24
        let hours = totalHours % 24

        switch (days, hours) {
        case (0, let h): return "\(h) hours later"
        case (let d, 0): return "\(d == 1 ? "1 day" : "\(d) days") later"
        case (let d, let h): return "\(d == 1 ? "1 day" : "\(d) days") and \(h) hours later"
        }
    }

    // Array of the labels
    var forecastLabels: [String] {
        guard let timelist = weather?.list else { return [] }
        return timelist.indices.map { labelForIndex($0) } // acts like (index in labelForIndex(index)) useful implementation to shorten code
    }
}

