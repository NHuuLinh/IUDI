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
import iOSDropDown


class RegisterViewController: UIViewController, CheckValid {
    
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var genderTF: DropDown!
    
    @IBOutlet weak var agreeTermBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    
    let keychain = KeychainSwift()
    var isRememberPassword = false
    let locationManager = CLLocationManager()
    var userLongitude : String?
    var userLatitude : String?
    var userIpAdress : String?
    var userData : UserDataRegister?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkInput()
        userPasswordTF.text = keychain.get("password")
        checkLocationAuthorizationStatus()
        dropDownHandle(texfield: genderTF, inputArray: Constant.gender)
    }
    override func viewWillAppear(_ animated: Bool) {
        requestLocation()
        
    }
    @IBAction func UserInputDidChanged(_ sender: UITextField) {
        checkInput()
    }
    @IBAction func handleBtn(_ sender: UIButton) {
        switch sender {
        case agreeTermBtn :
            checkBoxHandle()
            checkInput()
        case genderBtn :
            genderTF.showList()
        case registerBtn :
            registerHandle()
        case loginBtn:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
        texfield.arrowColor = UIColor .red
        texfield.selectedRowColor = UIColor .red
        texfield.optionArray = inputArray
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
    
    func registerHandle() {
        showLoading(isShow: true)
        guard let username = userNameTF.text,
              let userpassword = userPasswordTF.text,
              let userEmail = userEmailTF.text,
              let longitude = userLongitude,
              let latitude = userLatitude,
              let ipAdress = userIpAdress else {
            print("user nil")
            showLoading(isShow: false)
            showAlert(title: "Lỗi", message: "Vui lòng thử lại sau")
            return
        }
        let parameters: [String: Any] = [
            "Username": username,
            "FullName": username,
            "Email": userEmail,
            "Password": userpassword,
            "Latitude": longitude,
            "Longitude": latitude,
            "LastLoginIP": ipAdress
        ]
        
        APIService.share.apiHandle(method: .post ,subUrl: "register", parameters: parameters, data: UserDataRegister.self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(let data):
                    print("data: \(data)")
                        self.showLoading(isShow: false)
                case .failure(let error):
                    switch error {
                    case .server(let message), .network(let message):
                        self.showAlert(title: "Lỗi", message: message)
                        print("\(message)")
                    }
                }
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
                self.userLongitude = String(Int(currentLongitude))
                self.userLatitude = String(Int(currentLatitude))
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
            showLoading(isShow: false)
            return
        }
        APIService.share.getLocationByAPI { [weak self] (longtitude, latitude, ipAdress) in
            guard let self = self else {
                return
            }
            self.userIpAdress = ipAdress
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
            self?.userLongitude = String(Int(currentLongitude))
            self?.userLatitude = String(Int(currentLatitude))
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
            APIService.share.getLocationByAPI { [weak self] (longtitude, latitude, ipAdress) in
                guard let self = self else {
                    return
                }
                self.userLongitude = longtitude
                self.userLatitude = latitude
                self.userIpAdress = ipAdress
            }
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
