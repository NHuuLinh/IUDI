//
//  HomeViewController.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import UIKit
import CardSlider

struct Item: CardSliderItem {
    var rating: Int?
    var title: String
    var subtitle: String?
    var description: String?
    var image: UIImage
}

class HomeViewController: UIViewController {
    var data = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    

    @IBAction func logoutBtn(_ sender: Any) {
        UserDefaults.standard.didLogin = false
        AppDelegate.scene?.goToLogin()
    }
}
    

