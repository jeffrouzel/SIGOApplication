//
//  ViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/20/26.
//

// nsdate
import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    // Views
    @IBOutlet weak var mainInfo: UIView!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var sunView: UIView!
    
    // Dropdown UI Components
    @IBOutlet weak var forecastDD: UIStackView!
    @IBOutlet weak var btn_dropdown: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Data UI Components
    @IBOutlet weak var lbl_intervalForecast: UILabel!
    
    @IBOutlet weak var icon_condition: UIImageView!
    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var lbl_temp: UILabel!
    @IBOutlet weak var lbl_feelslike: UILabel!
    
    @IBOutlet weak var lbl_minTemp: UILabel!
    @IBOutlet weak var lbl_maxTemp: UILabel!
    
    @IBOutlet weak var lbl_humidity: UILabel!
    @IBOutlet weak var lbl_rainChance: UILabel!
    @IBOutlet weak var lbl_wind: UILabel!
    
    @IBOutlet weak var lbl_sunrise: UILabel!
    @IBOutlet weak var lbl_sunset: UILabel!
    
    var weatherViewModel: WeatherViewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // UI modifications
        mainInfoUI()
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
    
    // MARK: - Data Binding
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
    // MARK: - Passing of values
    private func showContent() {
        pickerView.reloadAllComponents()
        
        lbl_intervalForecast.text = "\(weatherViewModel.forecastIndexLabel)   \(weatherViewModel.forecastRangeText)"
        
        lbl_city.text = weatherViewModel.cityName
        lbl_temp.text = weatherViewModel.temperatureText
        lbl_feelslike.text = weatherViewModel.feelsLikeText
        lbl_minTemp.text = weatherViewModel.minTempText
        lbl_maxTemp.text = weatherViewModel.maxTempText
        icon_condition.image = UIImage(systemName: weatherViewModel.weatherIconName)
        
        lbl_humidity.text = weatherViewModel.humidityText
        lbl_rainChance.text = weatherViewModel.precipitationChance
        lbl_wind.text = weatherViewModel.windSpeedText
        
        lbl_sunrise.text = weatherViewModel.sunriseText
        lbl_sunset.text = weatherViewModel.sunsetText

    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.locationManager.startUpdatingLocation()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - UI MODIFICATIONS
    private func mainInfoUI(){
        orangeBorder(view: mainInfo)
        
        temperatureView.layer.cornerRadius = 8
        lbl_minTemp.layer.cornerRadius = 16
        lbl_maxTemp.layer.cornerRadius = 16
        
        orangeBorder(view: detailsView)
        orangeBorder(view: sunView)
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

    // MARK: - SEE WEATHER TIP ACTION
    @IBAction func seeWeatherTip(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tipView = storyboard.instantiateViewController(withIdentifier: "WeatherTipVC") as! WeatherTipVC
        
        tipView.weatherTip = weatherViewModel.weatherTip
        tipView.iconName = weatherViewModel.weatherIconName
        tipView.title = "\(weatherViewModel.weatherDatePageTitle) - Weather Tip"
        tipView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(tipView, animated: true)
    }
}
// MARK: - MAPS DATASOURCE AND DELEGATE
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

// MARK: - DROPDOWN DATASOURCE AND DELEGATE
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
        
        navigationItem.title = "Forecast: \(weatherViewModel.weatherDatePageTitle)"
    }
}

