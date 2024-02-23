//
//  RegisterViewController.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import CoreLocation

class RegisterViewController: UIViewController, checkValid {
    
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var agreeTermBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    let keychain = KeychainSwift()
    var isRememberPassword = false
    let locationManager = CLLocationManager()
    var longitude : String?
    var latitude : String?
    var userData : UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        case registerBtn :
            registerHandle()
        case agreeTermBtn :
            checkBoxHandle()
            checkInput()
        case loginBtn:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    func setupView(){
        standardBorder(textField: userNameTF)
        standardBorder(textField: userEmailTF)
        standardBorder(textField: userPasswordTF)
    }
    
    func saveUserInfo(){
        guard let userName = userNameTF.text, let password = userPasswordTF.text else {
            return
        }
        keychain.set(password, forKey: "password")
        keychain.set(userName, forKey: "username")
    }
    
    func checkBoxHandle(){
        let checkImage = UIImage(systemName: "checkmark.square")
        let uncheckImage = UIImage(named: "Rectangle 8")
        let buttonImage = agreeTermBtn.isSelected ? uncheckImage : checkImage
        agreeTermBtn.setBackgroundImage(buttonImage, for: .normal)
        print("\(agreeTermBtn.isSelected)")
        agreeTermBtn.isSelected = !agreeTermBtn.isSelected
        print("remenber pw")
    }
    
    func checkInput() {
        guard let userName = userNameTF.text, let userEmail = userEmailTF.text, let userPassword = userPasswordTF.text else {
            registerBtn.isEnabled = false
            registerBtn.layer.opacity = 0.5
            return
        }
        if checkUserNameValid(userName: userName) && emailValidator(email: userEmail) && passwordValidator(password: userPassword) && agreeTermBtn.isSelected {
            registerBtn.isEnabled = true
            registerBtn.layer.opacity = 1
        }else {
            registerBtn.isEnabled = false
            registerBtn.layer.opacity = 0.5
        }
    }
    func registerHandle(){
        showLoading(isShow: true)
        guard let userName = userNameTF.text, let userPassword = userPasswordTF.text else {
            showLoading(isShow: false)
            return
        }
        let url = Constant.baseUrl + "register"
        let parameters: [String: Any] = [
            "Username": userName,
            "FullName": userName,
            "Password": userPassword,
            "Latitude": latitude,
            "Longitude": longitude
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: UserData.self) { response in
                switch response.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .success(let data):
                    DispatchQueue.main.async {
                        self.userData = data
                        guard let userID = self.userData?.user?.users?.first?.userID else {
                            return
                        }
                        UserDefaults.standard.set(userID, forKey: "UserID")
                        print("data: \(userID)")
                    }
                    self.saveUserInfo()
                    UserDefaults.standard.didLogin = true
                    self.showLoading(isShow: false)
                    AppDelegate.scene?.goToHome()
                    // Xử lý thông tin người dùng đã đăng ký thành công tại đây (nếu cần)
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print(errorMessage)
                            self.showAlert(title: "Lỗi", message: errorMessage)
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                            self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                        }
                    } else {
                        print("Không có dữ liệu từ server")
                        self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                    }
                    self.showLoading(isShow: false)
                }
            }
    }
    
    
}
// MARK: - Các hàm liên quan vị trí
extension RegisterViewController: CLLocationManagerDelegate {
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
