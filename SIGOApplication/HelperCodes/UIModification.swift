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
