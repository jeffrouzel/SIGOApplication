//
//  MainTabBarController.swift
//  SIGOApplication
//
//  Created by training2 on 4/26/26.
//
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

//    private func setupTabBarAppearance() {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white
//
//        // Selected tab color
//        appearance.stackedLayoutAppearance.selected.iconColor = .systemOrange
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
//            .foregroundColor: UIColor.systemOrange
//        ]
//
//        // Unselected tab color
//        appearance.stackedLayoutAppearance.normal.iconColor = .gray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
//            .foregroundColor: UIColor.gray
//        ]
//
//        tabBar.standardAppearance = appearance
//        tabBar.scrollEdgeAppearance = appearance
//    }
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        // Selected — dark neutral instead of orange
        appearance.stackedLayoutAppearance.selected.iconColor = .label
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        // Unselected — muted
        appearance.stackedLayoutAppearance.normal.iconColor = .tertiaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.tertiaryLabel
        ]

        tabBar.standardAppearance   = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
