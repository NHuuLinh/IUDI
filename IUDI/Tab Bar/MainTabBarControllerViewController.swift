//
//  MainTabBarControllerViewController.swift
//  IUDI
//
//  Created by LinhMAC on 05/03/2024.
//

import UIKit

class MainTabBarControllerViewController: UITabBarController {
    @IBOutlet weak var test: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func setupTabBar() {
        let tabBarVC = UITabBarController()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            print("Failed to instantiate HomeViewController from storyboard")
            return
        }
//        homeVC.title = "Home"
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        
        
        homeNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Home-UnSelect"), selectedImage: UIImage(named: "Home-Selected"))
        
        let filterVC = FilterViewController()
//        filterVC.title = "Filter"
        let filterNavVC = UINavigationController(rootViewController: filterVC)
        filterNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Location-UnSelect"), selectedImage: UIImage(named: "Location-Selected"))
        
        let settingVC = SettingViewController()
//        filterVC.title = "Filter"
        let settingNavVC = UINavigationController(rootViewController: settingVC)
        settingNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Setting-UnSelect"), selectedImage: UIImage(named: "Setting-Selected"))
        
        tabBarVC.viewControllers = [homeNavVC, filterNavVC,settingNavVC]
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.tabBar.tintColor = UIColor(named: "MainColor")
        tabBarVC.tabBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        tabBarVC.tabBar.layer.opacity = 1
        tabBarVC.tabBar.itemPositioning = .fill
        present(tabBarVC, animated: true)
    }

}

