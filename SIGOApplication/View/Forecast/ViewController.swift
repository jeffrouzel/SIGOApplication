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
    @IBOutlet weak var btn_dropdown: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var chevronIcon: UIImageView!
    
    // Data UI Components
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
    
    @IBOutlet weak var btn_weatherTip: UIButton!
    
    @IBOutlet var detailLabels: [UILabel]!
    var weatherViewModel: WeatherViewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dropdown
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
        // UI
        updateUI()
        pickerView.reloadAllComponents()
        
        // pass on values
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
    private func updateUI() {
        let isDay = weatherViewModel.isDay
        setCardsnBackground()

        // Main Info
        mainInfoUI(isDay: isDay)
        // Dropdown button
        dropdownButtonUI(isDay: isDay)
        // Detail labels
        detailLabelColors(isDay: isDay)
        
        // Weather Tip button
        var tipConfig = btn_weatherTip.configuration
        tipConfig?.baseBackgroundColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        btn_weatherTip.configuration = tipConfig
    }
    private func setCardsnBackground() {
        let isDay = weatherViewModel.isDay
        view.setGradientBackground(isDay: isDay)

        // Card colors stay here since they're specific to this screen
        let cardColor = isDay
            ? UIColor.white.withAlphaComponent(0.85)
            : UIColor.white.withAlphaComponent(0.1)

        [mainInfo, temperatureView, detailsView, sunView].forEach {
            $0?.backgroundColor = cardColor
        }
    }
// MARK: - Main Info Related UI
    private func mainInfoUI(isDay: Bool) {
        mainInfo.styleAsCard()
        temperatureView.styleAsCard()
        detailsView.styleAsCard()
        sunView.styleAsCard()

        // Min/Max label pills
        lbl_minTemp.layer.cornerRadius = 8
        lbl_minTemp.clipsToBounds      = true
        lbl_maxTemp.layer.cornerRadius = 8
        lbl_maxTemp.clipsToBounds      = true
        
        // Labels (Main Info)
        lbl_city.textColor = isDay ? .systemOrange : .white
        lbl_temp.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        icon_condition.tintColor = isDay ? UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1) : .systemYellow
    }
// MARK: - LABEL (Details Info)
    private func detailLabelColors(isDay:Bool){
        detailLabels.forEach { $0.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1) }
        lbl_humidity.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        lbl_rainChance.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        lbl_wind.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        lbl_sunrise.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        lbl_sunset.textColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        
    }
// MARK: - Dropdown Related UI
    private func dropdownButtonUI(isDay: Bool) {
        var dd_config = btn_dropdown.configuration ?? UIButton.Configuration.filled()
        
        dd_config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes
            updated.font = UIFont.boldSystemFont(ofSize: 25)
            return updated
        }
        
        dd_config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes
            updated.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return updated
        }
        
        dd_config.baseBackgroundColor = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        
        dd_config.title = "\(weatherViewModel.forecastRangeText)"
        dd_config.subtitle = "\(weatherViewModel.forecastIndexLabel) \(weatherViewModel.weatherDatePageTitle)"
        btn_dropdown.configuration = dd_config
    }
    
        // MARK: Dropdown Button Action
    @IBAction func dropdownTapped(_ sender: UIButton) {
        let shouldShow = pickerView.isHidden

        if shouldShow {
            pickerView.isHidden = false
            pickerView.alpha    = 0
            chevronIcon.image = UIImage(systemName: "chevron.up")
        }

        UIView.animate(withDuration: 0.25) {
            self.pickerView.alpha = shouldShow ? 1 : 0
        } completion: { _ in
            if !shouldShow {
                self.pickerView.isHidden = true
                self.chevronIcon.image = UIImage(systemName: "chevron.down")
            }
        }
    }
    // MARK: - NAVIGATION (SEE WEATHER TIP ACTION)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWeatherTip",
           let dest = segue.destination as? WeatherTipVC {
            dest.isDay      = weatherViewModel.isDay
            dest.weatherTip = weatherViewModel.weatherTip
            dest.iconName = weatherViewModel.weatherIconName
            dest.title = "\(weatherViewModel.weatherDatePageTitle) - Weather Tip"
            dest.hidesBottomBarWhenPushed = true
        }
    }
    @IBAction func seeWeatherTip(_ sender: UIButton) {
        performSegue(withIdentifier: "toWeatherTip", sender: self)
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
    }
}

