//
//  WeatherTipViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/24/26.
//
import UIKit

class WeatherTipVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var lbl_Condition: UILabel!
    @IBOutlet weak var icon_weather: UIImageView!
    @IBOutlet weak var lbl_weatherTip: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet var tipView: UIView!
    
    var weatherTip: String = ""
    var iconName: String = ""
    var isDay: Bool = true
    var condition: String = ""
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showContent()
    }
    // MARK: - PASS ON VALUES
    private func showContent() {
        // UI
        view.setGradientBackground(isDay: isDay)
        tipView.styleAsCard()
        
        header.backgroundColor    = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        header.layer.cornerRadius = 10
        header.clipsToBounds      = true
        
        icon_weather.tintColor = isDay ? .systemOrange : .systemYellow
        
        // pass on Values
        lbl_Condition.text = "Condition: \(condition)"
        lbl_weatherTip.text = weatherTip
        icon_weather.image = UIImage(systemName: iconName)
    }
}

