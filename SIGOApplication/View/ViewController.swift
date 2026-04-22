//
//  ViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/20/26.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var test1: UILabel!
    @IBOutlet weak var test2: UILabel!
    @IBOutlet weak var test3: UILabel!
    @IBOutlet weak var test4: UILabel!
    @IBOutlet weak var test5: UILabel!
    @IBOutlet weak var test6: UILabel!
    @IBOutlet weak var test7: UILabel!
    @IBOutlet weak var test8: UILabel!
    @IBOutlet weak var test9: UILabel!
    var weatherViewModel: WeatherViewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        bindViewModel()
        
    }
    // MARK: Data Binding
    private func bindViewModel() {
        weatherViewModel.onWeatherUpdate = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.showContent()
            }
        }
        weatherViewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message: message)
            }
        }
    }
    // MARK: Passing of values
    private func showContent() {
        test1.text = weatherViewModel.cityName
        test2.text = weatherViewModel.countryName
        test3.text = weatherViewModel.temperatureText
        test4.text = weatherViewModel.feelsLikeText
        test5.text = weatherViewModel.conditionText
        test6.text = weatherViewModel.humidityText
        test7.text = weatherViewModel.sunriseText
        test8.text = weatherViewModel.sunsetText
        test9.text = weatherViewModel.precipitationChance
    }
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.locationManager.startUpdatingLocation()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

}
// MARK: MAPS
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()

        weatherViewModel.fetchWeather(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: "Could not find location: \(error.localizedDescription)")
    }
}

