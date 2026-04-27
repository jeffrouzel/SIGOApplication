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
    @IBOutlet var tipView: UIView!
    
    var weatherTip: String = ""
    var iconName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_weatherTip.text = weatherTip
        icon_weather.image = UIImage(systemName: iconName)
        orangeBorder(view: tipView)
    }
}

