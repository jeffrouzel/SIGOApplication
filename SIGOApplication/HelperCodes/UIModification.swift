//
//  UIModification.swift
//  SIGOApplication
//
//  Created by training2 on 4/24/26.
//
import UIKit

func orangeBorder(view: UIView){
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.orange.cgColor
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
}

func styleAsCard(_ view: UIView) {
    view.backgroundColor     = UIColor.white.withAlphaComponent(0.85)
    view.layer.cornerRadius  = 16
    view.layer.shadowColor   = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.08
    view.layer.shadowOffset  = CGSize(width: 0, height: 4)
    view.layer.shadowRadius  = 8
    view.clipsToBounds       = false
}
