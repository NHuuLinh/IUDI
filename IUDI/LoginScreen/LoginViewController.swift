//
//  LoginViewController.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import CoreLocation

class LoginViewController: UIViewController, CheckValid {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var rememberPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    let keychain = KeychainSwift()
    var isRememberPassword = false
    let locationManager = CLLocationManager()
    var longitude : String?
    var latitude : String?
    var userData : UserDataLogin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkInput()
        checkLocationAuthorizationStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
        requestLocation()
    }
    @IBAction func UserInputDidChanged(_ sender: UITextField) {
        checkInput()
        setupView()
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
    func setupView(){
//        userNameTF.text = keychain.get("username")
//        userPasswordTF.text = keychain.get("password")
        rememberPasswordBtn.isSelected = true
        // Đặt hình ảnh ban đầu cho nút
        let checkImage = UIImage(systemName: "checkmark.square")
        rememberPasswordBtn.setBackgroundImage(checkImage, for: .normal)
        standardBorder(textField: userNameTF)
        standardBorder(textField: userPasswordTF)
        standardBtnCornerRadius(button: loginBtn)
    }
    
    func saveUserInfo(){
        guard let userName = userNameTF.text, let password = userPasswordTF.text else {
            return
        }
        if rememberPasswordBtn.isSelected {
            keychain.set(password, forKey: "password")
        } else {
            keychain.delete("password")
            print("password không được lưu")
        }
        keychain.set(userName, forKey: "username")
    }
    
    func checkBoxHandle(){
        let checkImage = UIImage(systemName: "checkmark.square")
        let uncheckImage = UIImage(named: "Rectangle 8")
        let buttonImage = rememberPasswordBtn.isSelected ? uncheckImage : checkImage
        rememberPasswordBtn.setBackgroundImage(buttonImage, for: .normal)
        print("\(rememberPasswordBtn.isSelected)")
        rememberPasswordBtn.isSelected = !rememberPasswordBtn.isSelected
    }
    
    func checkInput() {
        guard let userName = userNameTF.text, let userPassword = userPasswordTF.text else {
            loginBtn.isEnabled = false
            loginBtn.layer.opacity = 0.5
            print("fail")
            return
        }
        if checkUserNameValid(userName: userName) && passwordValidator(password: userPassword){
            loginBtn.isEnabled = true
            loginBtn.layer.opacity = 1
            print("true")
        }else {
            loginBtn.isEnabled = false
            loginBtn.layer.opacity = 0.5
            print("fail")
        }
    }
    func loginHandle() {
        showLoading(isShow: true)
        guard let username = userNameTF.text,
              let password = userPasswordTF.text,
              let longitude = longitude,
              let latitude = latitude else {
            print("user nil")
            showLoading(isShow: false)
            showAlert(title: "Lỗi", message: "Vui lòng thử lại sau")
            return
        }
        let parameters: [String: Any] = [
            "Username": username,
            "Password": password,
            "Latitude": latitude,
            "Longitude": longitude
        ]
        APIService.share.apiHandle(subUrl: "login", parameters: parameters, data: UserDataLogin.self) { result in
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.userData = data
                        guard let userID = self.userData?.loginData?.users?.first?.userID else {
                            return
                        }
                        UserDefaults.standard.set(userID, forKey: "UserID")
                        print("data: \(userID)")
                    }
                    self.saveUserInfo()
                    UserDefaults.standard.didLogin = true
                    self.showLoading(isShow: false)
                    AppDelegate.scene?.goToHome()
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .failure(let error):
                    switch error {
                    case .server(let message):
                        self.showAlert(title: "lỗi", message: message)
                    case .network(let message):
                        self.showAlert(title: "lỗi", message: message)
                    }
                }
            }
        }
    }
}
// MARK: - Các hàm liên quan vị trí
extension LoginViewController: CLLocationManagerDelegate {
    func getLocationByAPI(){
        struct Location: Codable {
            let lat, lon: Double
            let city: String
        }
        showLoading(isShow: true)
        let url = "http://ip-api.com/json"
        AF.request(url).validate().responseDecodable(of: Location.self) { response in
            switch response.result {
            case .success(let location):
                let currentLongitude = location.lon
                let currentLatitude = location.lat
                self.longitude = String(Int(currentLongitude))
                self.latitude = String(Int(currentLatitude))
                self.showLoading(isShow: false)
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                self.showAlert(title: "Lỗi", message: error.localizedDescription)
            }
        }
    }
    
    func fetchCurrentLocation() {
        showLoading(isShow: true)
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
            self?.longitude = String(Int(currentLongitude))
            self?.latitude = String(Int(currentLatitude))
            self?.showLoading(isShow: false)
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
            getLocationByAPI()
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
