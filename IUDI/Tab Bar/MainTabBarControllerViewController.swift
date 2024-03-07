//
//  MainTabBarControllerViewController.swift
//  IUDI
//
//  Created by LinhMAC on 05/03/2024.
//

import UIKit

class MainTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()

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
        present(tabBarVC, animated: true)
    }
    func setupTabBar1() {
        let tabBarVC = UITabBarController()
        
        let homeVC = HomeViewController()
        homeVC.title = "Home"
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        homeNavVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "Home-Selected"), selectedImage: UIImage(named: "Home-Selected"))
        
        let filterVC = FilterViewController()
        filterVC.title = "Filter"
        let filterNavVC = UINavigationController(rootViewController: filterVC)
        filterNavVC.tabBarItem = UITabBarItem(title: "Filter", image: UIImage(named: "Location-Selected"), selectedImage: UIImage(named: "Location-UnSelect"))
        
        tabBarVC.viewControllers = [homeNavVC, filterNavVC]
        
        present(tabBarVC, animated: true)
    }

}
