//
//  ViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/20/26.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    // Dropdown UI Components
    @IBOutlet weak var forecastDD: UIStackView!
    @IBOutlet weak var btn_dropdown: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Data UI Components
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var lbl_temp: UILabel!
    @IBOutlet weak var lbl_minTemp: UILabel!
    @IBOutlet weak var lbl_maxTemp: UILabel!
    
    var weatherViewModel: WeatherViewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dropdown
        dropdownUI()
        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        // Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // View Model
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
        pickerView.reloadAllComponents()
        
        lbl_city.text = weatherViewModel.cityName
        lbl_temp.text = weatherViewModel.temperatureText
        lbl_minTemp.text = weatherViewModel.minTempText
        lbl_maxTemp.text = weatherViewModel.maxTempText
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.locationManager.startUpdatingLocation()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: Dropdown Related UI
    @IBAction func dropdownTapped(_ sender: UIButton) {
        pickerView.isHidden.toggle()
        
        btn_dropdown.configuration?.subtitle = pickerView.isHidden ? "Show forecast times" : "Select a forecast time"
    }
    
    private func dropdownUI(){
        forecastDD.layer.borderWidth = 1
        forecastDD.layer.borderColor = UIColor.black.cgColor
        forecastDD.layer.cornerRadius = 8
        forecastDD.clipsToBounds = true
    }
}
// MARK: MAPS DATASOURCE AND DELEGATE
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

// MARK: DROPDOWN DATASOURCE AND DELEGATE
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // Only needs one as I am only picking one, not like a date with many picks
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weatherViewModel.forecastLabels.count
    }
    // Show the labels
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weatherViewModel.forecastLabels[row]
    }
    // Update the UI
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weatherViewModel.selectedIndex = row
        showContent()
        pickerView.isHidden = true
    }
}

