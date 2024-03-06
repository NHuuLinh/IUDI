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
        homeVC.title = "Home"
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        homeNavVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let filterVC = FilterViewController()
        filterVC.title = "Filter"
        let filterNavVC = UINavigationController(rootViewController: filterVC)
        filterNavVC.tabBarItem = UITabBarItem(title: "Filter", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell.fill"))
        
        tabBarVC.viewControllers = [homeNavVC, filterNavVC]
        tabBarVC.modalPresentationStyle = .fullScreen
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
