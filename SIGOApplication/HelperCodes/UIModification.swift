//
//  UIModification.swift
//  SIGOApplication
//
//  Created by training2 on 4/24/26.
//
import UIKit

extension UIView {
    func styleAsCard() {
        backgroundColor     = UIColor.white.withAlphaComponent(0.85)
        layer.cornerRadius  = 16
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        clipsToBounds       = false
    }
    func styleAsCardLightOrange(){
        backgroundColor     = .systemOrange.withAlphaComponent(0.15)
        layer.cornerRadius  = 16
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        clipsToBounds       = false
    }
    func styleAsCardOrange() {
        backgroundColor     = .systemOrange
        layer.cornerRadius  = 16
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        clipsToBounds       = false
    }
    func styleAsFloatingButton() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        layer.borderWidth    = 1.5
        layer.borderColor    = UIColor.white.withAlphaComponent(0.6).cgColor
        clipsToBounds       = false
    }
    func setGradientBackground(isDay: Bool) {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.frame = bounds
        
        // Light Colors for Day
        if isDay {
            gradient.colors = [
                UIColor.white.cgColor,
                UIColor.systemOrange.cgColor
            ]
        // Dark Colors for Night
        } else {
            gradient.colors = [
                UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1).cgColor,
                UIColor(red: 0.0, green: 0.4, blue: 0.35, alpha: 1).cgColor
            ]
        }

        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }
    func styleAsCircleLabelLightOrange(color: UIColor = .systemOrange) {
        backgroundColor     = color.withAlphaComponent(0.50)
        layer.cornerRadius  = frame.height / 2
        clipsToBounds       = true
    }
}
extension UISearchBar {
    func styleRounded(cornerRadius: CGFloat = 12) {
        searchBarStyle = .minimal
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
