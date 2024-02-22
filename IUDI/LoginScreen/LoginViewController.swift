//
//  LoginViewController.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var rememberPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInput()
        
    }
    @IBAction func UserInputDidChanged(_ sender: UITextField) {
        checkInput()
    }
    @IBAction func handleBtn(_ sender: UIButton) {
        switch sender {
        case loginBtn :
            loginHandle()
        case rememberPasswordBtn :
            print("remenber pw")
        default:
            break
        }
    }
    
    func checkInput() {
        if (userNameTF.text?.count == 0) || (userPasswordTF.text?.count == 0) {
            loginBtn.isEnabled = false
            loginBtn.layer.opacity = 0.5
            print("fail")
        } else {
            loginBtn.isEnabled = true
            loginBtn.layer.opacity = 1
            print("true")
            
        }
    }
    //https://api.iudi.xyz
    func loginHandle(){
        let userName = userNameTF.text
        let userPassword = userPasswordTF.text
        let url = Constant.baseUrl + "login"
        let parameters: [String: Any] = [
            "Username": "admin",
            "Email" : "pxlphap@gmail.com",
            "Password": "pxl^@123",
            "Latitude": "27",
            "Longitude": "40"
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                    print("Response: \(value)")
                    
                    // Xử lý thông tin người dùng đã đăng ký thành công tại đây (nếu cần)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}
