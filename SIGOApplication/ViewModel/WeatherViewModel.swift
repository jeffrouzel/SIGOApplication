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
    
    // MARK: - UI RELATED
    // NIGHT/DAY SETTER
    var isDay: Bool {
        guard let forecast = selectedForecast else { return true }
        guard let timezone = weather?.city.timezone else { return true }
        return isDayTime(unix: forecast.dt, timezone: timezone)
    }
    // MARK: - HEAD DATA
    var cityName: String {
        weather?.city.name ?? ""
    }

    var countryName: String {
        weather?.city.country ?? ""
    }
    // MARK: - FOR WEATHER FORECAST LIST (up to 40 items, every 3 hrs interval for 5 days)
    
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
    
    // MARK: FORECAST DATA (MAIN)
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
    
    // MARK: FORECAST DATA (DETAILS)
    // Humidity
    var humidityText: String {
        guard let humidity = selectedForecast?.main.humidity else { return "--" }
        return "\(humidity)%"
    }
    // Rain Related
    var precipitationChance: String {
        guard let pop = selectedForecast?.pop else { return "--" }
        return "\(Int((pop * 100).rounded()))%"
    }
    // Wind
    var windSpeedText: String {
        guard let windSpeed = selectedForecast?.wind.speed else { return "--" }
        return "\(Int(windSpeed.rounded())) km/h"
    }
    
    
    
    var sunriseText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunrise, timezone: weather.city.timezone)
    }

    var sunsetText: String {
        guard let weather else { return "--:--" }
        return formatTime(weather.city.sunset, timezone: weather.city.timezone)
    }
//     Weather Items
    var conditionText: String {
        selectedForecast?.weather.first?.description.capitalized ?? "Unknown"
    }
    
    
//    var rainDropSize: String? {
//        guard let threeHourRainData = selectedForecast?.rain else { return "--" }
//        return "\(threeHourRainData) mm"
//    }

    // MARK: - Logic for WeatherIcons
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
    // MARK: - DATA FOR Forecast Interval
    var forecastIndexLabel: String {
        selectedIndex < 6 ? "Today:" : "Forecast:"
    }
    var forecastRangeText: String {
        guard let weather = weather,
              let forecast = selectedForecast else { return "--:--" }

        let start = formatTime(forecast.dt, timezone: weather.city.timezone)
        let end   = formatTime(forecast.dt + 3 * 3600, timezone: weather.city.timezone)

        return "\(start) - \(end)"
    }
    
    // Labels for Dropdown Picker
    func labelForIndexDD(_ index: Int) -> String {
        if index == 0 { return "Latest Available" }
        
        let totalHours = index * 3
        let days = totalHours / 24
        let hours = totalHours % 24

        switch (days, hours) {
        case (0, let h): return "+ \(h)Hrs"
        case (let d, 0): return "\(d == 1 ? "+ 1 Day" : "+ \(d) Days")"
        case (let d, let h): return "+ \("\(d)D") & \(h)Hrs"
        }
    }

    // Array of the labels
    var forecastLabels: [String] {
        guard let timelist = weather?.list else { return [] }
        return timelist.indices.map { labelForIndexDD($0) } // acts like (index in labelForIndex(index)) useful implementation to shorten code
    }
    // MARK: - LOGIC FOR WEATHER TIPS
    var weatherTip: String {
        guard let forecast = selectedForecast else { return "" }

        let condition = forecast.weather.first?.main.lowercased() ?? ""
        let pop = Int((forecast.pop * 100).rounded())
        let temp = Int(forecast.main.temp.rounded())
        let humidity = forecast.main.humidity

        switch condition {
        case "rain", "drizzle":
            if pop >= 70 {
                return "Careful there is a high chance of rain. Bringing an umbrella is a must"
            } else {
                return "Low chance of rain, but bringing an umbrella wouldn't hurt."
            }

        case "thunderstorm":
            return "⚠️ Thunderstorm ahead. It is better to avoid going out and stay indoors."

        case "clear":
            if temp >= 35 {
                return "⚠️ Caution!! High temperature of \(temp)°C. Stay hydrated and bring a fan."
            } else if temp >= 30 {
                return "Warm and clear. Great weather, just watch the heat."
            } else {
                return isDay ? "Clear skies today. Enjoy the weather!" : "Clear night sky tonight. Good for stargazing!!"
            }

        case "clouds":
            if humidity >= 80 {
                return "Cloudy and humid at \(humidity)%. It may feel hotter than it looks."
            } else {
                return "Overcast skies. Comfortable enough to head out."
            }

        // May not occur due to location set in PH
        case "snow":
            return "Snow expected. Be careful on icy roads and dress warmly."

        case "mist", "fog", "haze":
            return "⚠️ Low visibility due to \(condition). Have caution while traveling."

        default:
            return "Good to headout, Have a nice day!"
        }
    }
    var weatherDatePageTitle: String {
        guard let forecast = selectedForecast,
              let weather = weather else { return "Weather Tip" }
        return formatDate(forecast.dt, timezone: weather.city.timezone)
    }
}

