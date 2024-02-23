//
//  HomeViewController.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutBtn(_ sender: Any) {
        UserDefaults.standard.didLogin = false
        AppDelegate.scene?.goToLogin()
    }
}
