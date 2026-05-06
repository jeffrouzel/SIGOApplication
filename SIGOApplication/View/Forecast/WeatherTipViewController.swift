//
//  WeatherTipViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/24/26.
//
import UIKit

class WeatherTipVC: UIViewController {
    
    @IBOutlet weak var icon_weather: UIImageView!
    @IBOutlet weak var lbl_weatherTip: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet var tipView: UIView!
    
    var weatherTip: String = ""
    var iconName: String = ""
    var isDay: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showContent()
    }
    
    private func showContent() {
        // UI
        view.setGradientBackground(isDay: isDay)
        tipView.styleAsCard()
        
        header.backgroundColor    = isDay ? .systemOrange : UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1)
        header.layer.cornerRadius = 10
        header.clipsToBounds      = true
        
        icon_weather.tintColor = isDay ? .systemOrange : .systemYellow
        
        // pass on Values
        lbl_weatherTip.text        = weatherTip
        icon_weather.image         = UIImage(systemName: iconName)
    }
}

