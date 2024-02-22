//
//  LoginViewController.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import CoreLocation

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var rememberPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    let keychain = KeychainSwift()
    var isRememberPassword = false
    let locationManager = CLLocationManager()
    var longitude : Int?
    var latitude : Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInput()
        userPasswordTF.text = keychain.get("password")
        checkLocationAuthorizationStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
        requestLocation()
        
    }
    @IBAction func UserInputDidChanged(_ sender: UITextField) {
        checkInput()
    }
    @IBAction func handleBtn(_ sender: UIButton) {
        switch sender {
        case loginBtn :
            loginHandle()
        case rememberPasswordBtn :
            checkBoxHandle()
        case registerBtn:
            goToRegisterVC()
        default:
            break
        }
    }
    
    func goToRegisterVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "RegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func savePassword(){
        if rememberPasswordBtn.isSelected {
            guard let password = userPasswordTF.text else {
                return
            }
            keychain.set(password, forKey: "password")
        } else {
            print("password không được lưu")
        }
    }
    func checkBoxHandle(){
        let checkImage = UIImage(named: "App Icone")
        let uncheckImage = UIImage(named: "Rectangle 8")
        let buttonImage = rememberPasswordBtn.isSelected ? uncheckImage : checkImage
        rememberPasswordBtn.setBackgroundImage(buttonImage, for: .normal)
        print("\(rememberPasswordBtn.isSelected)")
        rememberPasswordBtn.isSelected = !rememberPasswordBtn.isSelected
        print("remenber pw")
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
    
    func loginHandle(){
        let userName = userNameTF.text
        let userPassword = userPasswordTF.text
        let url = Constant.baseUrl + "login"
        let parameters: [String: Any] = [
            "Username": userName,
            //            "Email" : "pxlphap@gmail.com",
            "Password": userPassword,
            "Latitude": "27",
            "Longitude": "40"
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: UserData.self) { data in
                switch data.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .success(let data):
                    print("data: \(data.user?.users?.first?.userID)")
                    self.savePassword()
                    // Xử lý thông tin người dùng đã đăng ký thành công tại đây (nếu cần)
                case .failure(let error):
                    print("\(error)")
                }
            }
    }
}
// MARK: - Các hàm liên quan vị trí
extension LoginViewController: CLLocationManagerDelegate {
    func fetchCurrentLocation() {
        //        showLoading(isShow: true)
        // check xem có đia điểm hiện tại không,nếu không thì không làm gì cả
        guard let currentLocation = locationManager.location else {
            print("Current location not available.")
            return
        }
        let geocoder = CLGeocoder()
        // lấy placemark
        geocoder.reverseGeocodeLocation(currentLocation) { [weak self] (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }
            let currentLongitude = currentLocation.coordinate.longitude
            let currentLatitude = currentLocation.coordinate.latitude
            self?.longitude = Int(currentLongitude)
            self?.latitude = Int(currentLatitude)
            print("currentLongitude: \(self?.longitude)")
            print("currentLatitude: \(self?.latitude)")
            
        }
    }
    
    func requestLocation() {
        print("requestLocation")
        
        // đưa nó vào một luồng khác để tránh làm màn hình người dùng đơ
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                // khai báo delegate để nhận thông tin thay đổi trạng thái vị trí
                self.locationManager.delegate = self
                // yêu cầu độ chính xác khi dò vi trí
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                // update vị trí cho các hàm của CLLocationManager
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func checkLocationAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Yêu cầu quyền sử dụng vị trí khi ứng dụng đang được sử dụng
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlert(title: "Ok", message: "Please allow to use location")
            break
        case .authorizedWhenInUse, .authorizedAlways:
            // Bắt đầu cập nhật vị trí và gọi api nếu được cấp quyền
            locationManager.startUpdatingLocation()
            fetchCurrentLocation()
        @unknown default:
            break
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Kiểm tra lại trạng thái ủy quyền khi nó thay đổi
        checkLocationAuthorizationStatus()
    }
}
